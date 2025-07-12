#!/bin/bash -l
#SBATCH --cpus-per-task=192  
#SBATCH --nodes=1
#SBATCH --time=24:00:00 
#SBATCH --account=ag-trebst
#SBATCH --partition=smp
#SBATCH --output=/scratch/%u/%j/job.out
#SBATCH --error=/scratch/%u/%j/job.err
#SBATCH --array=0-3

workdir=/scratch/${USER}/${SLURM_JOB_ID}  
mkdir -p $workdir

JULIA_NUM_THREADS=$SLURM_CPUS_PER_TASK

depth=15
averaging=20000
resolution=$JULIA_NUM_THREADS
L_array=(128 256 512 1024)
L=${L_array[$SLURM_ARRAY_TASK_ID]}

julia -t $JULIA_NUM_THREADS -e "include(./entanglement_half.jl); simulate(\"$workdir\"; depth=$depth, L=$L, averaging=$averaging, resolution=$resolution);"

