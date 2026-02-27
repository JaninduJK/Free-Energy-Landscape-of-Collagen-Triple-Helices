#!/usr/bin/env bash
set -u  # don't use -e (so failures won't stop the loop)

NP=16
GMX_MPI="gmx_mpi"

# Your conf list (in the exact order you gave)
confs=(
     652 653 655 656 657 658 661 663 665 669
     671 675 678 682 684 689 694 696 698 700
     703 710 712 714 715 716 717 719 721 723 
     725 726 728
  )

i=79
for c in "${confs[@]}"; do
  conf="conf${c}.gro"
  tpr="npt${i}.tpr"
  deffnm="npt${i}"

  echo "======================================"
  echo "Starting: $conf  ->  $deffnm"
  echo "======================================"

  if [[ ! -f "$conf" ]]; then
    echo "ERROR: missing $conf -> skipping npt$i"
    echo ""
    i=$((i+1))
    continue
  fi

  # grompp (index file corrected)
  $GMX_MPI grompp -f npt_umb.mdp -c "$conf" -p topol.top -r "$conf" -n index.ndx -o "$tpr" -maxwarn 1
  if [[ $? -ne 0 ]]; then
    echo "ERROR: grompp failed for $conf (npt$i) -> moving to next"
    echo ""
    i=$((i+1))
    continue
  fi

  # mdrun
  mpirun -np "$NP" $GMX_MPI mdrun -deffnm "$deffnm" -v
  if [[ $? -ne 0 ]]; then
    echo "ERROR: mdrun failed for npt$i -> moving to next"
    echo ""
    i=$((i+1))
    continue
  fi

  echo "npt window $i finished"
  echo ""

  i=$((i+1))
done

echo "All NPT windows attempted. Total windows = ${#confs[@]}"
