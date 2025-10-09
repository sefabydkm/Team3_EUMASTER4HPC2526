#!/bin/bash -l
#SBATCH --job-name=start_db
#SBATCH --time=00:15:00
#SBATCH --qos=default
#SBATCH --partition=cpu
#SBATCH --account=p200981
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G

echo "=== Starting PostgreSQL ==="
echo "Date: $(date)"
echo "Hostname: $(hostname -s)"

module load Apptainer

# Container ismini belirle
DB_IMG=postgres_15.sif

# Container yoksa çek
if [ ! -f "$DB_IMG" ]; then
  echo "Pulling PostgreSQL container..."
  apptainer pull $DB_IMG docker://postgres:15
fi

# Create data directory (separate for each job)
DATA_DIR=/tmp/postgres_data_$SLURM_JOB_ID
mkdir -p "$DATA_DIR"

# Initialize PostgreSQL if first time
if [ ! -f "$DATA_DIR/PG_VERSION" ]; then
  echo "📦 Creating database cluster..."
  apptainer exec \
    --env PGDATA=/var/lib/postgresql/data \
    --bind "$DATA_DIR":/var/lib/postgresql/data \
    $DB_IMG bash -c "initdb -D /var/lib/postgresql/data"
fi

# Allow remote access
echo "🔧 Configuring pg_hba.conf..."
echo "host    all             all             0.0.0.0/0               md5" >> "$DATA_DIR/pg_hba.conf"

# Starting PostgreSQL
echo "🚀 Starting PostgreSQL..."
apptainer exec \
  --env PGDATA=/var/lib/postgresql/data \
  --bind "$DATA_DIR":/var/lib/postgresql/data \
  $DB_IMG bash -c "postgres -D /var/lib/postgresql/data \
    -c listen_addresses='*' \
    -c port=5432 \
    -c "unix_socket_directories='/tmp'" \
    -c "external_pid_file='/tmp/postgres_5432.pid'" \
    -c max_connections=20 \
    -c shared_buffers=128MB \
    -c work_mem=2MB \
    -c maintenance_work_mem=32MB \
    -c checkpoint_completion_target=0.9 \
    -c wal_buffers=8MB \
    -c default_statistics_target=100 \
    -c random_page_cost=1.1 \
    -c effective_io_concurrency=200 \
    -c max_worker_processes=2 \
    -c max_parallel_workers_per_gather=1 \
    -c max_parallel_workers=2 \
    -c max_parallel_maintenance_workers=1" &

sleep 10

echo "✅ Database ready!"
echo "Hostname: $(hostname -s)"
echo "Port: 5432"
echo "User: postgres"
echo "Password: (empty — you can set with -e POSTGRES_PASSWORD if needed)"

# Test if PostgreSQL is running
apptainer exec \
  --bind "$DATA_DIR":/var/lib/postgresql/data \
  $DB_IMG pg_isready -h localhost -p 5432

# Keep job active
while true; do
  sleep 60
  echo "$(date): Database is running..."
done
