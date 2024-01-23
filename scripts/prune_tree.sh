#!/bin/bash

#SBATCH -p evlab
#SBATCH --ntasks=1 
#SBATCH --time=0:20:00
#SBATCH --mem=4G
#SBATCH --output=./slurm_log/prune_tree%j.out

source ~/.local/bin/activate-conda
conda activate r_glotto

echo 'executing prune_tree.sh'
date

Rscript prune_tree.R


echo 'finished!'
date