#!/bin/bash

#SBATCH -p evlab
#SBATCH --ntasks=1 
#SBATCH --time=0:20:00
#SBATCH --mem=4G
#SBATCH --output=./slurm_log/make_table%j.out

source ~/.local/bin/activate-conda
conda activate r_glotto

echo 'executing make_table.sh'
date

Rscript make_table.R


echo 'finished!'
date