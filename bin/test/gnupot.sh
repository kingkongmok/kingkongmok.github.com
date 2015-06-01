#!/bin/bash
gnuplot <<- EOF
set terminal png 
set output '~/Downloads/simple.1.png'
set key inside left top vertical Right noreverse enhanced autotitle box lt black linewidth 1.000 dashtype solid
set samples 50, 50
set title "Simple Plots" 
set title  font "~/.font/DejaVuSansMono, 30" norotate
plot [-10:10] sin(x),atan(x),cos(atan(x))
EOF
