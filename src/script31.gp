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

set yrange [0:4000]

set title "Switch-many, seting out number of yield"
set xlabel "Number of Threads"
set ylabel "Computing time (µs)"
set output "build/graph-31-threads.pdf"
plot 'build/data-pthread-31-1a.txt' u 2:3 smooth bezier w l ls 1 t 'With pthread, 1 yield', 'build/data-31-1a.txt' u 2:3 smooth bezier w l ls 2 t 'With User Thread, 1 yield', 'build/data-pthread-31-1b.txt' u 2:3 smooth bezier w l ls 3 t 'With pthread, 10 yields', 'build/data-31-1b.txt' u 2:3 smooth bezier w l ls 4 t 'With User Thread, 10 yields', 'build/data-pthread-31-1c.txt' u 2:3 smooth bezier w l ls 5 t 'With pthread, 50 yields', 'build/data-31-1c.txt' u 2:3 smooth bezier w l ls 6 t 'With User Thread, 50 yields'

set title "Switch-many, seting out number of thread"
set xlabel "Number of Yields"
set ylabel "Computing time (µs)"
set output "build/graph-31-yields.pdf"
plot 'build/data-pthread-31-2a.txt' u 1:3 smooth bezier w l ls 1 t 'With pthread, 1 thread', 'build/data-31-2a.txt' u 1:3 smooth bezier w l ls 2 t 'With User Thread, 1 thread', 'build/data-pthread-31-2b.txt' u 1:3 smooth bezier w l ls 3 t 'With pthread, 10 threads', 'build/data-31-2b.txt' u 1:3 smooth bezier w l ls 4 t 'With User Thread, 10 threads', 'build/data-pthread-31-2c.txt' u 1:3 smooth bezier w l ls 5 t 'With pthread, 50 threads', 'build/data-31-2c.txt' u 1:3 smooth bezier w l ls 6 t 'With User Thread, 50 threads'
