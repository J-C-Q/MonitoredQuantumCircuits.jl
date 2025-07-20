#!/bin/bash -l
#SBATCH --cpus-per-task=128  
#SBATCH --nodes=1
#SBATCH --time=24:00:00 
#SBATCH --output=/scratch/hpc-prf-pm2frg/pm2frg14/Fibonacci/%j/job.out
#SBATCH --error=/scratch/hpc-prf-pm2frg/pm2frg14/Fibonacci/%j/job.err
#SBATCH --array=0-3

workdir=/scratch/hpc-prf-pm2frg/pm2frg14/Fibonacci/${SLURM_JOB_ID}
mkdir -p $workdir

JULIA_NUM_THREADS=$SLURM_CPUS_PER_TASK

depth=15
averaging=20000
resolution=$JULIA_NUM_THREADS
L_array=(128 256 512 1024)
L=${L_array[$SLURM_ARRAY_TASK_ID]}

julia -t $JULIA_NUM_THREADS -e "include(./entanglement_half.jl); simulate(\"$workdir\"; depth=$depth, L=$L, averaging=$averaging, resolution=$resolution);"

