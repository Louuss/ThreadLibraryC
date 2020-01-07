#include "thread.h"
#include "QueueBSD.h"

#define CLOCKID CLOCK_REALTIME
#define SIG SIGRTMIN

/* Intervalle du timer en ns */
#define NANOSEC 1e7

/* Nombres de cycles de timer au bout duquel on change le thread qui 
 * s'exécute si celui-ci n'a pas changé au cours de ces cycles */
#define COMPTEUR_LIMIT 1 

timer_t timerid;
struct sigevent sev;
struct itimerspec its;
long long freq_nanosecs;
sigset_t mask;
struct sigaction sa;

SIMPLEQ_HEAD(head_list, thread) thread_list = SIMPLEQ_HEAD_INITIALIZER( thread_list );

/* Permet de définir un identifiant unique pour un thread */
int i = 1;
/* Compte le nombre de cycles de timer pendant lequel un thread s'exécute */
int cpt = 0;
/* Booléen permettant l'initialisation du programme */
int init = 0;
/* Représente le thread exécutant lors du dernier cycle de timer */
thread_t previous_running = NULL;
pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
ucontext_t mainContext;

struct thread{
  int id;
  void * returnValue;
  SIMPLEQ_ENTRY(thread) list;
  ucontext_t context;
  int valgrind_stackid;
  int terminated;
};

/*
 * Affiche les id des threads contenus dans la file.
 */

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


/*
 * Fonction appelée par le timer toutes les NANOSEC nanosecondes,
 * appelle thread_yield si le thread courant ne change pas au bout de COMPTEUR_LIMIT cycles de timer.
 */

static void handler(){
  thread_t current_thread = thread_self();
  if (previous_running == current_thread){
    cpt++;
    if (cpt >= COMPTEUR_LIMIT){
      cpt = 0;
      thread_yield();
    }
  }
  else{
    previous_running = current_thread;
    cpt = 0;
  }
}


/*
 * Fonction passée en argument de thread_create, permet d'être sûr qu'on 
 * appelle thread_exit une fois le thread exécuté
 */

void wrapper(void*(*func)(void*), void* funcarg){
    void * res = func(funcarg);
    thread_exit(res);
}


/*
 * Initialise la librairie en mettant le thread principal dans la file,
 * initialise également les variables utiles au timer
 */

extern void init_lib(){
    struct thread * init_thread = malloc(sizeof(struct thread));
    init_thread->id = 0;
    getcontext(&(init_thread->context));
    getcontext(&mainContext);
    init_thread->valgrind_stackid = -1;
    init_thread->terminated = 0;

    SIMPLEQ_INSERT_HEAD(&thread_list, init_thread, list);

    init = 1;
    previous_running = init_thread;

    memset (&sa, 0, sizeof(sa));

    /* Définit le handler comme fonction associée à la réception du signal */

    sa.sa_flags = SA_SIGINFO;
    sa.sa_sigaction = handler;
    sigemptyset(&sa.sa_mask);
    sigaction(SIG, &sa, NULL);

    sigemptyset(&mask);
    sigaddset(&mask, SIG);

    /* Crée le timer */

    sev.sigev_notify = SIGEV_SIGNAL;
    sev.sigev_signo = SIG;
    sev.sigev_value.sival_ptr = &timerid;
    timer_create(CLOCKID, &sev, &timerid);

    /* Démarre le timer */

    its.it_value.tv_nsec = NANOSEC;
    its.it_interval.tv_nsec = its.it_value.tv_nsec;
    timer_settime(timerid, 0, &its, NULL);
}


/*
 * Libère les ressources
 */

__attribute__ ((destructor)) extern void end_lib (void) {
    struct thread * current = thread_self();
    if (current->valgrind_stackid != -1) {
      VALGRIND_STACK_DEREGISTER(current->valgrind_stackid);
      free(current->context.uc_stack.ss_sp);
    }
    free(current);
    timer_delete(timerid);
}


/*
 * Récupère le thread courant.
 */

extern thread_t thread_self(void){
  if ( !init ) {
    init_lib();
  }
  struct thread *mythread = SIMPLEQ_FIRST(&thread_list);
  return mythread;
}


/*
 * Créer un nouveau thread qui va exécuter la fonction func avec l'argument funcarg,
 * renvoie 0 en cas de succès, -1 en cas d'erreur.
 */

extern int thread_create(thread_t *newthread, void *(*func)(void *), void *funcarg){
  if ( !init ) {
      init_lib();
  }
  struct thread * thread = malloc(sizeof(struct thread));
  if (thread == NULL){
    return -1;
  }
  thread->id = i;
  i++;
  thread->returnValue = NULL;
  thread->terminated = 0;
  getcontext(&(thread->context));
  thread->context.uc_link = NULL;
  thread->context.uc_stack.ss_size = 64*1024;
  thread->context.uc_stack.ss_sp = malloc(thread->context.uc_stack.ss_size);
  thread->valgrind_stackid = VALGRIND_STACK_REGISTER(thread->context.uc_stack.ss_sp,
                                                     thread->context.uc_stack.ss_sp + thread->context.uc_stack.ss_size);
  
  sigprocmask(SIG_BLOCK, &mask, NULL);
  makecontext(&(thread->context), (void (*)(void)) wrapper, 2, func, funcarg );
  *newthread = thread;
  struct thread * head_thread = SIMPLEQ_FIRST(&thread_list);
  SIMPLEQ_INSERT_HEAD(&thread_list, thread, list);
  swapcontext(&(head_thread->context), &(thread->context));
  sigprocmask(SIG_UNBLOCK, &mask, NULL);
  
  return 0;
}


/*
 * Passe la main à un autre thread.
 */

extern int thread_yield(void){
  if ( !init ) {
    init_lib();
  }
  if ( sigprocmask(SIG_BLOCK, &mask, NULL ) == -1){
        perror ("yield: sigprocmask block fail \n");
        exit(0);
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
  
  /*Réinitialisation du timer lorsqu'on passe la main */
  its.it_value.tv_nsec = NANOSEC;
  its.it_interval.tv_nsec = its.it_value.tv_nsec;
  timer_settime(timerid, 0, &its, NULL);

  if ( sigprocmask(SIG_UNBLOCK, &mask, NULL ) == -1){
        perror ("yield: sigprocmask unblock fail \n");
        exit(0);
  }
  return 0;
}


/*
 * Attend la fin d'exécution d'un thread.
 * La valeur renvoyée par le thread est placée dans *retval.
 * Si retval est NULL, la valeur de retour est ignorée.
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


/*
 * Termine le thread courant en renvoyant la valeur de retour retval.
 */

 extern void thread_exit(void *retval) // __attribute__ ((__noreturn__))
{
    if ( !init ) {
        init_lib();
    }
    struct thread * current = thread_self();
    struct thread * next;
    sigprocmask(SIG_BLOCK, &mask, NULL);
    SIMPLEQ_REMOVE_HEAD(&thread_list, list);
    assert( current->terminated == 0 );
    current->terminated = 1;
    current->returnValue = retval;
    next = SIMPLEQ_FIRST(&thread_list);
    if ( next && (current-> valgrind_stackid == -1)){
        swapcontext(&mainContext, &next->context);
        exit (0);
    }
    if ( next ){
       setcontext( &next->context );
    }
    SIMPLEQ_INSERT_HEAD(&thread_list, current,list);
    setcontext(&mainContext);
}


/*
    Initialise le mutex passé en paramètre et retourne 0 si
    l'initialisation s'est bien passée
*/
int thread_mutex_init(thread_mutex_t *mutex)
{
  if(mutex ==NULL)
    return -1;
    
  mutex->locked=0;
  return 0;
}

/*
    Sert à détruire le mutex 
*/
int thread_mutex_destroy(thread_mutex_t *mutex)
{
  return 0;
}
/*
    Teste si le mutex passe en parametre est verouille et verouille le mutex
    quand il est disponible
    Retourne 0 en cas de reussite
*/
int thread_mutex_lock(thread_mutex_t *mutex)
{
  if (mutex == NULL)
    return -1;

  while(mutex->locked == 1 )
    thread_yield();

  mutex->locked = 1;

  return 0;

}
/*
    Deverouille le mutex passe en parametre et retourne 0 si succes
*/
int thread_mutex_unlock(thread_mutex_t *mutex)
{
  if(mutex == NULL)
    return -1;

  mutex->locked=0;
  return 0;
}
