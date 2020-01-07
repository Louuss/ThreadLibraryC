#!/bin/sh

#rm -f build/graph-*
#echo "Veuillez patienter environ 15 secondes pour l'execution des tests..."
FILES31="build/data-31-1a.txt build/data-31-1b.txt build/data-31-1c.txt build/data-31-2a.txt build/data-31-2b.txt build/data-31-2c.txt
build/data-pthread-31-1a.txt build/data-pthread-31-1b.txt build/data-pthread-31-1c.txt
build/data-pthread-31-2a.txt build/data-pthread-31-2b.txt build/data-pthread-31-2c.txt"
FILES32="build/data-32-1a.txt build/data-32-1b.txt build/data-32-1c.txt build/data-32-2a.txt build/data-32-2b.txt build/data-32-2c.txt
build/data-pthread-32-1a.txt build/data-pthread-32-1b.txt build/data-pthread-32-1c.txt
build/data-pthread-32-2a.txt build/data-pthread-32-2b.txt build/data-pthread-32-2c.txt"


if (( $1=='51' ))
then
  echo -n "" > build/data-pthread-51.txt;
  rm -f build/graph-fibo*.pdf
  for i in `seq 1 16`
  do
    ./build/51-fibonacci-pthread $i | cut -d ' ' -f3,5,7 >> build/data-pthread-51.txt;
  done;

  echo -n "" > build/data-51.txt; \
  for i in `seq 1 24`; do \
    ./build/51-fibonacci $i | grep -e ^[f] | cut -d ' ' -f3,5,7 >> build/data-51.txt; \
  done
  gnuplot src/script51.gp
fi

if (($1=='31'))
then
  rm -f build/graph-31*
  for file in $FILES31; do
    echo -n "" > $file
  done
  for i in `seq 1 20`; do \
    for rep in `seq 1 5`; do \
      ./build/31-switch-many $i 1 | grep -e ^[1] | cut -d ' ' -f1,4,6 >> build/data-31-1a.txt; \
      ./build/31-switch-many-pthread $i 1 | grep -e ^[1] | cut -d ' ' -f1,4,6 >> build/data-pthread-31-1a.txt; \
      ./build/31-switch-many $i 10 | grep -e ^[1] | cut -d ' ' -f1,4,6 >> build/data-31-1b.txt; \
      ./build/31-switch-many-pthread $i 10 | grep -e ^[1] | cut -d ' ' -f1,4,6 >> build/data-pthread-31-1b.txt; \
      ./build/31-switch-many $i 50 | grep -e ^[5] | cut -d ' ' -f1,4,6 >> build/data-31-1c.txt; \
      ./build/31-switch-many-pthread $i 50 | grep -e ^[5] | cut -d ' ' -f1,4,6 >> build/data-pthread-31-1c.txt; \
      ./build/31-switch-many 1 $i | grep -e ^[1-9] | cut -d ' ' -f1,4,6 >> build/data-31-2a.txt; \
      ./build/31-switch-many-pthread 1 $i | grep -e ^[1-9] | cut -d ' ' -f1,4,6 >> build/data-pthread-31-2a.txt; \
      ./build/31-switch-many 10 $i | grep -e ^[1-9] | cut -d ' ' -f1,4,6 >> build/data-31-2b.txt; \
      ./build/31-switch-many-pthread 10 $i | grep -e ^[1-9] | cut -d ' ' -f1,4,6 >> build/data-pthread-31-2b.txt; \
      ./build/31-switch-many 50 $i | grep -e ^[1-9] | cut -d ' ' -f1,4,6 >> build/data-31-2c.txt; \
      ./build/31-switch-many-pthread 50 $i | grep -e ^[1-9] | cut -d ' ' -f1,4,6 >> build/data-pthread-31-2c.txt; \
    done;
  done;
  for i in `seq 21 50`; do \
    for rep in `seq 1 3`; do \
      ./build/31-switch-many $i 1 | grep -e ^[1] | cut -d ' ' -f1,4,6 >> build/data-31-1a.txt; \
      ./build/31-switch-many-pthread $i 1 | grep -e ^[1] | cut -d ' ' -f1,4,6 >> build/data-pthread-31-1a.txt; \
      ./build/31-switch-many $i 10 | grep -e ^[1] | cut -d ' ' -f1,4,6 >> build/data-31-1b.txt; \
      ./build/31-switch-many-pthread $i 10 | grep -e ^[1] | cut -d ' ' -f1,4,6 >> build/data-pthread-31-1b.txt; \
      ./build/31-switch-many $i 50 | grep -e ^[5] | cut -d ' ' -f1,4,6 >> build/data-31-1c.txt; \
      ./build/31-switch-many-pthread $i 50 | grep -e ^[5] | cut -d ' ' -f1,4,6 >> build/data-pthread-31-1c.txt; \
      ./build/31-switch-many 1 $i | grep -e ^[1-9] | cut -d ' ' -f1,4,6 >> build/data-31-2a.txt; \
      ./build/31-switch-many-pthread 1 $i | grep -e ^[1-9] | cut -d ' ' -f1,4,6 >> build/data-pthread-31-2a.txt; \
      ./build/31-switch-many 10 $i | grep -e ^[1-9] | cut -d ' ' -f1,4,6 >> build/data-31-2b.txt; \
      ./build/31-switch-many-pthread 10 $i | grep -e ^[1-9] | cut -d ' ' -f1,4,6 >> build/data-pthread-31-2b.txt; \
      ./build/31-switch-many 50 $i | grep -e ^[1-9] | cut -d ' ' -f1,4,6 >> build/data-31-2c.txt; \
      ./build/31-switch-many-pthread 50 $i | grep -e ^[1-9] | cut -d ' ' -f1,4,6 >> build/data-pthread-31-2c.txt; \
    done
  done
  for i in `seq 51 10 991`; do \
    for rep in `seq 1 2`; do \
      ./build/31-switch-many $i 1 | grep -e ^[1] | cut -d ' ' -f1,4,6 >> build/data-31-1a.txt; \
      ./build/31-switch-many-pthread $i 1 | grep -e ^[1] | cut -d ' ' -f1,4,6 >> build/data-pthread-31-1a.txt; \
      ./build/31-switch-many $i 10 | grep -e ^[1] | cut -d ' ' -f1,4,6 >> build/data-31-1b.txt; \
      ./build/31-switch-many-pthread $i 10 | grep -e ^[1] | cut -d ' ' -f1,4,6 >> build/data-pthread-31-1b.txt; \
      ./build/31-switch-many $i 50 | grep -e ^[5] | cut -d ' ' -f1,4,6 >> build/data-31-1c.txt; \
      ./build/31-switch-many-pthread $i 50 | grep -e ^[5] | cut -d ' ' -f1,4,6 >> build/data-pthread-31-1c.txt; \
      ./build/31-switch-many 1 $i | grep -e ^[1-9] | cut -d ' ' -f1,4,6 >> build/data-31-2a.txt; \
      ./build/31-switch-many-pthread 1 $i | grep -e ^[1-9] | cut -d ' ' -f1,4,6 >> build/data-pthread-31-2a.txt; \
      ./build/31-switch-many 10 $i | grep -e ^[1-9] | cut -d ' ' -f1,4,6 >> build/data-31-2b.txt; \
      ./build/31-switch-many-pthread 10 $i | grep -e ^[1-9] | cut -d ' ' -f1,4,6 >> build/data-pthread-31-2b.txt; \
      ./build/31-switch-many 50 $i | grep -e ^[1-9] | cut -d ' ' -f1,4,6 >> build/data-31-2c.txt; \
      ./build/31-switch-many-pthread 50 $i | grep -e ^[1-9] | cut -d ' ' -f1,4,6 >> build/data-pthread-31-2c.txt; \
    done
  done
  gnuplot src/script31.gp
fi

if (($1=='32'))
then
  rm -f build/graph-32*
  for file in $FILES32; do
    echo -n "" > $file
  done
  for i in `seq 1 20`; do \
    for rep in `seq 1 5`; do \
      ./build/32-switch-many-join $i 1 | grep -e ^[1-9] | cut -d ' ' -f1,4,6 >> build/data-32-1a.txt; \
      ./build/32-switch-many-join-pthread $i 1 | grep -e ^[1-9] | cut -d ' ' -f1,4,6 >> build/data-pthread-32-1a.txt; \
      ./build/32-switch-many-join $i 10 | grep -e ^[1-9] | cut -d ' ' -f1,4,6 >> build/data-32-1b.txt; \
      ./build/32-switch-many-join-pthread $i 10 | grep -e ^[1-9] | cut -d ' ' -f1,4,6 >> build/data-pthread-32-1b.txt; \
      ./build/32-switch-many-join $i 50 | grep -e ^[1-9] | cut -d ' ' -f1,4,6 >> build/data-32-1c.txt; \
      ./build/32-switch-many-join-pthread $i 50 | grep -e ^[1-9] | cut -d ' ' -f1,4,6 >> build/data-pthread-32-1c.txt; \
      ./build/32-switch-many-join 1 $i | grep -e ^[1-9] | cut -d ' ' -f1,4,6 >> build/data-32-2a.txt; \
      ./build/32-switch-many-join-pthread 1 $i | grep -e ^[1-9] | cut -d ' ' -f1,4,6 >> build/data-pthread-32-2a.txt; \
      ./build/32-switch-many-join 10 $i | grep -e ^[1-9] | cut -d ' ' -f1,4,6 >> build/data-32-2b.txt; \
      ./build/32-switch-many-join-pthread 10 $i | grep -e ^[1-9] | cut -d ' ' -f1,4,6 >> build/data-pthread-32-2b.txt; \
      ./build/32-switch-many-join 50 $i | grep -e ^[1-9] | cut -d ' ' -f1,4,6 >> build/data-32-2c.txt; \
      ./build/32-switch-many-join-pthread 50 $i | grep -e ^[1-9] | cut -d ' ' -f1,4,6 >> build/data-pthread-32-2c.txt; \
    done;
  done;
  for i in `seq 21 50`; do \
    for rep in `seq 1 3`; do \
      ./build/32-switch-many-join $i 1 | grep -e ^[1-9] | cut -d ' ' -f1,4,6 >> build/data-32-1a.txt; \
      ./build/32-switch-many-join-pthread $i 1 | grep -e ^[1-9] | cut -d ' ' -f1,4,6 >> build/data-pthread-32-1a.txt; \
      ./build/32-switch-many-join $i 10 | grep -e ^[1-9] | cut -d ' ' -f1,4,6 >> build/data-32-1b.txt; \
      ./build/32-switch-many-join-pthread $i 10 | grep -e ^[1-9] | cut -d ' ' -f1,4,6 >> build/data-pthread-32-1b.txt; \
      ./build/32-switch-many-join $i 50 | grep -e ^[1-9] | cut -d ' ' -f1,4,6 >> build/data-32-1c.txt; \
      ./build/32-switch-many-join-pthread $i 50 | grep -e ^[1-9] | cut -d ' ' -f1,4,6 >> build/data-pthread-32-1c.txt; \
      ./build/32-switch-many-join 1 $i | grep -e ^[1-9] | cut -d ' ' -f1,4,6 >> build/data-32-2a.txt; \
      ./build/32-switch-many-join-pthread 1 $i | grep -e ^[1-9] | cut -d ' ' -f1,4,6 >> build/data-pthread-32-2a.txt; \
      ./build/32-switch-many-join 10 $i | grep -e ^[1-9] | cut -d ' ' -f1,4,6 >> build/data-32-2b.txt; \
      ./build/32-switch-many-join-pthread 10 $i | grep -e ^[1-9] | cut -d ' ' -f1,4,6 >> build/data-pthread-32-2b.txt; \
      ./build/32-switch-many-join 50 $i | grep -e ^[1-9] | cut -d ' ' -f1,4,6 >> build/data-32-2c.txt; \
      ./build/32-switch-many-join-pthread 50 $i | grep -e ^[1-9] | cut -d ' ' -f1,4,6 >> build/data-pthread-32-2c.txt; \
    done
  done
  for i in `seq 51 10 991`; do \
    for rep in `seq 1 2`; do \
      ./build/32-switch-many-join $i 1 | grep -e ^[1-9] | cut -d ' ' -f1,4,6 >> build/data-32-1a.txt; \
      ./build/32-switch-many-join-pthread $i 1 | grep -e ^[1-9] | cut -d ' ' -f1,4,6 >> build/data-pthread-32-1a.txt; \
      ./build/32-switch-many-join $i 10 | grep -e ^[1-9] | cut -d ' ' -f1,4,6 >> build/data-32-1b.txt; \
      ./build/32-switch-many-join-pthread $i 10 | grep -e ^[1-9] | cut -d ' ' -f1,4,6 >> build/data-pthread-32-1b.txt; \
      ./build/32-switch-many-join $i 50 | grep -e ^[1-9] | cut -d ' ' -f1,4,6 >> build/data-32-1c.txt; \
      ./build/32-switch-many-join-pthread $i 50 | grep -e ^[1-9] | cut -d ' ' -f1,4,6 >> build/data-pthread-32-1c.txt; \
      ./build/32-switch-many-join 1 $i | grep -e ^[1-9] | cut -d ' ' -f1,4,6 >> build/data-32-2a.txt; \
      ./build/32-switch-many-join-pthread 1 $i | grep -e ^[1-9] | cut -d ' ' -f1,4,6 >> build/data-pthread-32-2a.txt; \
      ./build/32-switch-many-join 10 $i | grep -e ^[1-9] | cut -d ' ' -f1,4,6 >> build/data-32-2b.txt; \
      ./build/32-switch-many-join-pthread 10 $i | grep -e ^[1-9] | cut -d ' ' -f1,4,6 >> build/data-pthread-32-2b.txt; \
      ./build/32-switch-many-join 50 $i | grep -e ^[1-9] | cut -d ' ' -f1,4,6 >> build/data-32-2c.txt; \
      ./build/32-switch-many-join-pthread 50 $i | grep -e ^[1-9] | cut -d ' ' -f1,4,6 >> build/data-pthread-32-2c.txt; \
    done
  done
  gnuplot src/script32.gp
fi
