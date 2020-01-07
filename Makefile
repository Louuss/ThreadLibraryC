TST_DIR=tst
SRC_DIR=src
BLD_DIR=build
CC=gcc
VGD=valgrind --leak-check=yes -v --track-origins=yes --vgdb-error=1
CFLAGS=-Wall -Wextra -Isrc
VFLAGS=-Wall -Wextra -g -O0
CFLAGS2=-fPIC -shared

TST= tst/01-main.c \
	tst/02-switch.c \
	tst/11-join.c \
	tst/12-join-main.c \
	tst/21-create-many.c \
	tst/22-create-many-recursive.c \
	tst/23-create-many-once.c \
	tst/31-switch-many.c \
	tst/32-switch-many-join.c \
	tst/51-fibonacci.c \
	tst/61-mutex.c \
	tst/62-mutex.c

TST_GRAPHS= build/51-fibonacci-pthread build/51-fibonacci \
build/31-switch-many build/31-switch-many-pthread \
build/32-switch-many-join build/32-switch-many-join-pthread

TST_EXE=$(TST:.c=)
TST_EXE:=$(TST_EXE:tst/%=build/%)
TST_EXE_WARG=build/01-main \
	build/02-switch \
	build/11-join \
	build/12-join-main

TST_PTHREAD=$(TST:.c=-pthread)
TST_PTHREAD:=$(TST_PTHREAD:tst/%=build/%)

OBJS=
.SECONDARY: $(OBJS)

all : build test

build: $(BLD_DIR)/thread_copy.so #$(BLD_DIR)/thread.so

${BLD_DIR}/thread_copy.so: ${SRC_DIR}/thread_copy.c ${SRC_DIR}/thread.h build_dir
	${CC} ${CFLAGS} ${CFLAGS2} -c ${SRC_DIR}/thread_copy.c -o ${BLD_DIR}/thread_copy.so #$(BLD_DIR)/thread.so

build_dir:
	mkdir -p ${BLD_DIR}


${BLD_DIR}/%.o: ${TST_DIR}/%.c ${SRC_DIR}/thread.h build_dir
	${CC} ${CFLAGS} -c $< -o $@


${BLD_DIR}/%: ${BLD_DIR}/%.o ${BLD_DIR}/thread_copy.so #$(BLD_DIR)/thread.so
	${CC} ${LDFLAGS} -o $@ $^ -lrt

#--------------------------------------------------
${BLD_DIR}/%-pthread.o: ${TST_DIR}/%.c ${SRC_DIR}/thread.h build_dir
	${CC} ${CFLAGS} -DUSE_PTHREAD -c $< -o $@

${BLD_DIR}/%-pthread: ${BLD_DIR}/%-pthread.o
	${CC} ${LDFLAGS} -o $@ $^ -lpthread

#---------------------------------------------------
test: ${TST_EXE}

pthreads: ${TST_PTHREAD}

check: all
	@for test in $(TST_EXE_WARG); do \
		echo "Executing $${test} :"; \
		./$${test}; \
	done
	./build/21-create-many 10
	./build/22-create-many-recursive 10
	./build/23-create-many-once 10
	./build/31-switch-many 5 10
	./build/32-switch-many-join 10 5
	./build/51-fibonacci 23
	./build/61-mutex 20
	./build/62-mutex 20



clean:
	rm -rf build/ src/*.txt

valgrind: all
	@for test in ${TST_EXE_WARG} ; do \
		echo "Executing $${test} :" ; \
		$(VGD) ./$${test} ; \
	done
	$(VGD) ./build/21-create-many 10
	$(VGD) ./build/22-create-many-recursive 10
	$(VGD) ./build/23-create-many-once 10
	$(VGD) ./build/31-switch-many 5 10
	$(VGD) ./build/32-switch-many-join 10 5
	$(VGD) ./build/51-fibonacci 8
	$(VGD) ./build/61-mutex 20
	$(VGD) ./build/62-mutex 20

graphs: graph51 graph31 graph32


graph31: ${TST_GRAPHS}
	./src/graphs.sh 31

graph32: ${TST_GRAPHS}
	./src/graphs.sh 32

graph51: ${TST_GRAPHS}
	./src/graphs.sh 51
