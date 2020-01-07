#set terminal postscript eps enhanced color solid "Helvetica" 18
set terminal pdf enhanced color size 5,4 font "Helvetica,14"

#set grid x
#set grid y

#set title "Mordor"

# Black
# FlatTS / Elemental
# FlatTT / Scalapack
# Greedy / MKL
# Adaptatif
# Plasma

set style line 1 lt 0 lc rgb 'red' lw 2
set style line 2 lt 2 lc rgb 'red' lw 2
set style line 3 lt 0 lc rgb 'blue' lw 2
set style line 4 lt 2 lc rgb 'blue'  lw 2
set style line 5 lt 0 lc rgb 'green' lw 2
set style line 6 lt 2 lc rgb 'green' lw 2

set key left top Left reverse

set xlabel "Values tested with Fibonacci"
set ylabel "Computing time (s)"
set logscale y
set output "build/graph-fibo.pdf"
plot 'build/data-pthread-51.txt' u 1:3 smooth bezier w l lc 1 t 'With pthread', 'build/data-51.txt' u 1:3 smooth bezier w l lc 3 t 'With User Thread'

set xlabel "Values returned by Fibonacci"
set ylabel "Computing time (s)"
unset logscale y
set output "build/graph-fibo-res.pdf"
plot 'build/data-pthread-51.txt' u 2:3 smooth bezier w l lc 1 t 'With pthread', 'build/data-51.txt' u 2:3 smooth bezier w l lc 3 t 'With User Thread'
