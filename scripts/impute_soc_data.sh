#!/bin/bash

#SBATCH -p evlab
#SBATCH --ntasks=1 
#SBATCH --time=48:00:00
#SBATCH --mem=4G
#SBATCH --output=./slurm_log/impute_soc_data-%j.out

source ~/.local/bin/activate-conda
conda activate r_glotto

echo 'executing impute_soc_data.sh'
date

Rscript impute_soc_data.R

echo 'finished!'
date