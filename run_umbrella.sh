#!/usr/bin/env bash
set -u  # no -e, so it continues on errors

NP=16
GMX_MPI="gmx_mpi"

for i in {0..60}; do
  gro="npt${i}.gro"
  cpt="npt${i}.cpt"
  tpr="umbrella${i}.tpr"
  deffnm="umbrella${i}"

  echo "======================================"
  echo "Starting umbrella window $i"
  echo "======================================"

  if [[ ! -f "$gro" ]]; then
    echo "ERROR: missing $gro -> skipping window $i"
    echo ""
    continue
  fi

  if [[ ! -f "$cpt" ]]; then
    echo "ERROR: missing $cpt -> skipping window $i"
    echo ""
    continue
  fi

  # grompp
  $GMX_MPI grompp -f md_umb.mdp -c "$gro" -t "$cpt" -p topol.top -r "$gro" -n index_2col.ndx -o "$tpr"
  if [[ $? -ne 0 ]]; then
    echo "ERROR: grompp failed for window $i -> moving to next"
    echo ""
    continue
  fi

  # mdrun
  mpirun -np "$NP" $GMX_MPI mdrun -deffnm "$deffnm" -v
  if [[ $? -ne 0 ]]; then
    echo "ERROR: mdrun failed for window $i -> moving to next"
    echo ""
    continue
  fi

  echo "umbrella window $i finished"
  echo ""
done

echo "All umbrella windows (0..60) attempted."
