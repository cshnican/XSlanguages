#!/bin/bash

#SBATCH -p evlab
#SBATCH --ntasks=1 
#SBATCH --time=48:00:00
#SBATCH --mem=4G
#SBATCH --output=./slurm_log/analysis_soc_linear-%j.out

source ~/.local/bin/activate-conda
conda activate r_glotto

echo 'executing analysis_soc_linear.sh'
echo $1
date

Rscript analysis_soc_linear.R $1


echo 'finished!'
date