#!/bin/bash

#SBATCH -p evlab
#SBATCH --ntasks=1 
#SBATCH --time=2:20:00
#SBATCH --mem=2G
#SBATCH --output=./slurm_log/extract_fit-%j.out

source ~/.local/bin/activate-conda
conda activate r_glotto

echo 'executing extract_fit.sh'
date

Rscript extract_fit.R

echo 'finished!'
date