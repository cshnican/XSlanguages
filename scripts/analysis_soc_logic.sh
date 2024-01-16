#!/bin/bash

#SBATCH -p evlab
#SBATCH --ntasks=1 
#SBATCH --time=48:00:00
#SBATCH --mem=4G
#SBATCH --output=./slurm_log/analysis_soc_logic-%j.out

source ~/.local/bin/activate-conda
conda activate r_glotto

echo 'executing analysis_soc_logic.sh'
date

Rscript analysis_soc_logic.R 


echo 'finished!'
date