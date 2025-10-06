#!/bin/bash -l
#SBATCH -J LogReg_Benchmark
#SBATCH --output=logreg_%j.log
#SBATCH --time=00:15:00
#SBATCH --partition=cpu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --account=p200981

echo "Date: $(date)"
echo "Node: $(hostname -s)"
echo "Working dir: $(pwd)"

# Run the Logistic Regression container
srun apptainer run logreg_benchmark.sif train_logreg --n-samples 50000 --n-features 50
