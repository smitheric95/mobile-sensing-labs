#!/bin/bash

#SBATCH -J erics_cnn       # job name to display in squeue
#SBATCH -o output-%j.txt    # standard output file
#SBATCH -e error-%j.txt     # standard error file
#SBATCH -p gpgpu-1      # requested partition
#SBATCH -t 1440              # maximum runtime in minutes
#SBATCH -D /users/eric/scratch/MobileSensing
#SBATCH -s
#SBATCH --mail-type=all

module load python
source activate ML_Env_GPU

python ImageModel.py