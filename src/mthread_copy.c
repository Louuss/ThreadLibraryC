 #include "thread.h"
 #include "QueueBSD.h"



 #define DEBUG 1
 #if defined(DEBUG)
 #define myprintf( str, ... ) fprintf(stderr, str, #__VA_ARGS__ )
 #else
 #define myprintf( str, ... ) do {} while(0)
 #endif

 #define CLOCKID CLOCK_REALTIME
 #define SIG SIGRTMIN
 #define NANOSEC 1e7
 #define COMPTEUR_LIMIT 1

 struct thread{
   int id;
   void * returnValue;
   SIMPLEQ_ENTRY(thread) list;
   ucontext_t context;
   int valgrind_stackid;
   int terminated;
 };

 SIMPLEQ_HEAD(head_list, thread) thread_list = SIMPLEQ_HEAD_INITIALIZER( thread_list );

 int i = 1;
 int compteur = 0;
 int compteur2 = 0;
 int init = 0;
 thread_t previous_running = NULL;
 pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;

 void debugList()
 {
   struct thread * current;
   printf("\nDEBUG LIST \n");
   SIMPLEQ_FOREACH(current, &thread_list, list)
   {
     printf("ID: %d\n",current->id);
   }
   printf("END DEBUG\n\n" );
 }

 static void handler()
 {
     thread_t current_thread = thread_self();
     if (previous_running == current_thread){
         compteur++;
         if (compteur >= COMPTEUR_LIMIT){
             compteur = 0;
             printf("changement de contexte\n");
             thread_yield();
         }
     }
     else{
         previous_running = current_thread;
         compteur = 0;
     }
 }

 void wrapper(void*(*func)(void*), void* funcarg){
     void * res = func(funcarg);
     thread_exit(res);
 }

 /* Initialise la librairie avec le thread courant dans la file
 */
 extern void init_lib(){
     struct thread * init_thread = malloc(sizeof(struct thread));
     init_thread->id = 0;
     getcontext(&(init_thread->context));
     init_thread->valgrind_stackid = -1;
     init_thread->terminated = 0;

     SIMPLEQ_INSERT_HEAD(&thread_list, init_thread, list); // head elem field

     init = 1;
     previous_running = init_thread;

     timer_t timerid;
     struct sigevent sev;
     struct itimerspec its;
     long long freq_nanosecs;
     struct sigaction sa;

     /* Establish handler for timer signal */
     sa.sa_flags = SA_SIGINFO;
     sa.sa_sigaction = handler;
     sigemptyset(&sa.sa_mask);
     sigaction(SIG, &sa, NULL);

     /* Create the timer */

     sev.sigev_notify = SIGEV_SIGNAL;
     sev.sigev_signo = SIG;
     sev.sigev_value.sival_ptr = &timerid;
     timer_create(CLOCKID, &sev, &timerid);

     /* Start the timer */
     its.it_value.tv_nsec = NANOSEC;
     its.it_interval.tv_nsec = its.it_value.tv_nsec;

     timer_settime(timerid, 0, &its, NULL);
 }

 __attribute__ ((destructor))
 extern void end_lib (void) {
     struct thread * current = thread_self();
     // printf("%x\n", thread_self());
     free(current);

 }

 /* recuperer l'identifiant du thread courant.
  */
 extern thread_t thread_self(void){
   if ( !init ) {
     init_lib();
   }
   struct thread *mythread = SIMPLEQ_FIRST(&thread_list);
   return mythread;
 }

 /* creer un nouveau thread qui va exécuter la fonction func avec l'argument funcarg.
  * renvoie 0 en cas de succès, -1 en cas d'erreur.
  */
 extern int thread_create(thread_t *newthread, void *(*func)(void *), void *funcarg){
   // printf( "%s\n", __func__ );
   if ( !init ) {
       init_lib();
   }

   struct thread * thread = malloc(sizeof(struct thread));
   if (thread == NULL){
     return -1;
   }
   i++;
   thread->id = i;
   thread->returnValue = NULL;
   thread->terminated = 0;

   getcontext(&(thread->context));
   thread->context.uc_link = NULL;
   thread->context.uc_stack.ss_size = 64*1024;
   thread->context.uc_stack.ss_sp = malloc(thread->context.uc_stack.ss_size);

   thread->valgrind_stackid = VALGRIND_STACK_REGISTER(thread->context.uc_stack.ss_sp,
                                                      thread->context.uc_stack.ss_sp + thread->context.uc_stack.ss_size);
   makecontext(&(thread->context), (void (*)(void)) wrapper, 2, func, funcarg );

   *newthread = thread;
   struct thread * head_thread = SIMPLEQ_FIRST(&thread_list);

   //assert( head_thread != NULL );
   SIMPLEQ_INSERT_HEAD(&thread_list, thread, list);
   swapcontext(&(head_thread->context), &(thread->context));

   return 0;
 }

 /* passer la main à un autre thread.
  */
 extern int thread_yield(void){
   if ( !init ) {
     init_lib();
   }

   struct thread *first_thread = SIMPLEQ_FIRST(&thread_list);

   SIMPLEQ_REMOVE_HEAD(&thread_list, list);
   SIMPLEQ_INSERT_TAIL(&thread_list, first_thread, list);

   struct thread *second_thread = SIMPLEQ_FIRST(&thread_list);

   if ( first_thread != second_thread ) {
       assert( second_thread->terminated == 0 );
       swapcontext( &(first_thread->context),
                    &(second_thread->context));
   }

   return 0;
 }

 /* attendre la fin d'exécution d'un thread.
  * la valeur renvoyée par le thread est placée dans *retval.
  * si retval est NULL, la valeur de retour est ignorée.
  */
 extern int thread_join(thread_t thread, void **retval){


   struct thread * casted = (struct thread *) thread;
   struct thread * current = thread_self();
   if ( !init ) {
     init_lib();
   }


   while (casted->terminated == 0){
       thread_yield();
   }

   assert( current->terminated == 0 );
   assert( casted->terminated == 1 );
   // printf("%s:%d\n", __func__, __LINE__);

   if (retval != NULL) {

       *retval = casted->returnValue;
   }

   if (casted->valgrind_stackid != -1) {

       VALGRIND_STACK_DEREGISTER(casted->valgrind_stackid);

       free(casted->context.uc_stack.ss_sp);

   }
   free(casted);



   return 0;
 }

// /* terminer le thread courant en renvoyant la valeur de retour retval.
//  * cette fonction ne retourne jamais.
//  * L'attribut noreturn aide le compilateur à optimiser le code de
//  * l'application (élimination de code mort). Attention à ne pas mettre
//  * cet attribut dans votre interface tant que votre thread_exit()
//  * n'est pas correctement implémenté (il ne doit jamais retourner).
//  */
  extern void thread_exit(void *retval) // __attribute__ ((__noreturn__))
 {
     if ( !init ) {
         init_lib();
     }

     struct thread * current = thread_self();
     struct thread * next;

     SIMPLEQ_REMOVE_HEAD(&thread_list, list);
     assert( current->terminated == 0 );

     current->terminated = 1;
     current->returnValue = retval;

     next = SIMPLEQ_FIRST(&thread_list);

     if ( next ){
        setcontext( &next->context );
    }
 }
