#!/bin/bash -l

#SBATCH --job-name=ollama_job
#SBATCH --time=00:04:00
#SBATCH --qos=default
#SBATCH --partition=gpu
#SBATCH --account=p200981                      # Put your project ID
#SBATCH --nodes=1                          # num of nodes
#SBATCH --ntasks=1                       # number of tasks
#SBATCH --ntasks-per-node=1              # number of tasks per node



echo "Date              = $(date)"
echo "Hostname          = $(hostname -s)"
echo "Working Directory = $(pwd)"
echo "SLURM_PROCID      = $SLURM_PROCID"


# Load the container
module add  Apptainer 

# Run the service
apptainer pull docker://ollama/ollama
echo "Ollama container pulled"
echo "Starting Ollama service"
apptainer exec --nv ollama_latest.sif ollama serve
