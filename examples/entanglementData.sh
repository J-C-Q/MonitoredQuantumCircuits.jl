#!/bin/bash -x
#SBATCH --account=quantsim
#SBATCH --nodes=16
#SBATCH --ntasks=16
#SBATCH --output=mpi-out.%j
#SBATCH --error=mpi-err.%j
#SBATCH --time=24:00:00
#SBATCH --partition=mem192

srun -n 16 julia --project -tauto phaseEntanglementData.jl 