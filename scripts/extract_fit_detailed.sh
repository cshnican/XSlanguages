#!/bin/bash

#SBATCH -p evlab
#SBATCH --ntasks=1 
#SBATCH --time=2:20:00
#SBATCH --mem=8G
#SBATCH --output=./slurm_log/extract_fit_detailed-%j.out

source ~/.local/bin/activate-conda
conda activate r_glotto

echo 'executing extract_fit_detailed.sh'
date

Rscript extract_fit_detailed.R

echo 'finished!'
date