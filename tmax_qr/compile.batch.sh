#!/bin/bash

# This script runs multiple R scripts in parallel. Each R script (e.g. compile.coef.05.values.R)
# is taking the raw tmax coefficient (later SE) values from all the 4823 files and compiling
# into individual .csv files. E.g. a .csv file of all the coefficient values from the regression
# for the .05 quantile in a single .csv file (5268 x 4823). 

#SBATCH --job-name=xdec
#SBATCH --error=/scratch/users/tballard/tmin.extracts/cleaned/compile.errors.dec.err
#SBATCH --output=/scratch/users/tballard/tmin.extracts/cleaned/compile.terminal.output.dec.out
#SBATCH --qos=normal
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=60GB
#SBATCH --mail-type=END
#SBATCH --mail-user=tballard@stanford.edu
#SBATCH --time=8:00:00
#SBATCH -p diffenbaugh

ml use /share/sw/modules/all
ml load R

parallel -j0 Rscript :::: <(ls compile.coef.*.values.R)
                           
# parallel tells the machine to run in parallel..
# -j0 tells it to run as many jobs as possible
# Rscript is the terminal command for running a .R file