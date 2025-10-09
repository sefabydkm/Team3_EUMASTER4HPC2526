#!/bin/bash -l

#SBATCH --job-name=test_db
#SBATCH --time=00:05:00
#SBATCH --qos=default
#SBATCH --partition=cpu
#SBATCH --account=p200981
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=2G

echo "=== Database Test ==="
echo "Date: $(date)"
echo "Hostname: $(hostname -s)"

# Get database hostname parameter
DB_HOST=${1:-"localhost"}
DB_PORT=${2:-"5432"}

echo "Database Host: $DB_HOST"
echo "Database Port: $DB_PORT"

# Load container
module add Apptainer

# Test connection
echo "Connecting to database ($DB_HOST:$DB_PORT)..."
apptainer exec postgres_15.sif psql \
    -h $DB_HOST \
    -p $DB_PORT \
    -U postgres \
    -d postgres \
    -c "SELECT 'Database is working!' as status;"

# ping the database print
ping -c 1 $DB_HOST

if [ $? -eq 0 ]; then
    echo "✅ Database connection successful!"
else
    echo "❌ Database connection failed!"
fi

echo "Test completed!"
