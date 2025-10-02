#!/bin/bash -l


#SBATCH --job-name=example_job           
#SBATCH --time=00:05:00         
#SBATCH --qos=default       
#SBATCH --partition=cpu               
#SBATCH --account=p200981              
#SBATCH --nodes=1                    
#SBATCH --ntasks=8                
#SBATCH --ntasks-per-node=8          


# Basit test komutu
srun echo "Hello HPC from task $SLURM_PROCID"
