#!/bin/bash

GMX=/usr/local/gromacs2025.3/bin/gmx_mpi

echo 0 | $GMX trjconv -s pull1.tpr -f pull1.xtc -o conf.gro -sep

for (( i=0; i<1001; i++ ))
do
    $GMX distance -s pull1.tpr -f conf${i}.gro -n index_2col.ndx \
      -select 'com of group "Collagen1" plus com of group "Collagen2"' \
      -oall dist${i}.xvg
done

: > summary_distances.dat
for (( i=0; i<1001; i++ ))
do
    d=$(tail -n 1 dist${i}.xvg | awk '{print $2}')
    echo "${i} ${d}" >> summary_distances.dat
    rm -f dist${i}.xvg
done
