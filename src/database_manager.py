#!/usr/bin/env python3
"""
Database Manager - HPC PostgreSQL Database Controller
Usage: python database_manager.py [start|stop|status]
"""

import subprocess
import sys
import time
import os
import signal

class DatabaseManager:
    def __init__(self):
        self.script_dir = "/home/users/u102573/Team3_EUMASTER4HPC2526/src"
        self.start_script = "start_db.sh"
        self.test_script = "test_db.sh"
        self.current_job_id = None
        
    def run_command(self, command):
        """Run command and return result"""
        try:
            result = subprocess.run(command, shell=True, capture_output=True, text=True, cwd=self.script_dir)
            return result.returncode, result.stdout, result.stderr
        except Exception as e:
            return -1, "", str(e)
    
    def get_running_jobs(self):
        """Find running database jobs"""
        returncode, stdout, stderr = self.run_command("squeue -u $USER -h -o '%i %j'")
        if returncode == 0:
            jobs = []
            for line in stdout.strip().split('\n'):
                if line and 'start_db' in line:
                    parts = line.split()
                    if len(parts) >= 2:
                        jobs.append(parts[0])
            return jobs
        return []
    
    def start_database(self):
        """Start database"""
        print("🚀 Starting database...")
        
        # First check running jobs
        running_jobs = self.get_running_jobs()
        if running_jobs:
            print(f"⚠️  Database job already running: {running_jobs[0]}")
            return running_jobs[0]
        
        # Start database job
        returncode, stdout, stderr = self.run_command(f"sbatch {self.start_script}")
        if returncode == 0:
            job_id = stdout.strip().split()[-1]
            self.current_job_id = job_id
            print(f"✅ Database job started: {job_id}")
            print("⏳ Waiting 30 seconds for database to be ready...")
            time.sleep(30)
            return job_id
        else:
            print(f"❌ Failed to start database: {stderr}")
            return None
    
    def stop_database(self):
        """Stop database"""
        print("🛑 Stopping database...")
        
        running_jobs = self.get_running_jobs()
        if not running_jobs:
            print("⚠️  No running database job found")
            return False
        
        for job_id in running_jobs:
            returncode, stdout, stderr = self.run_command(f"scancel {job_id}")
            if returncode == 0:
                print(f"✅ Database job stopped: {job_id}")
            else:
                print(f"❌ Failed to stop job: {stderr}")
        
        return True
    
    def test_database(self):
        """Test database"""
        print("🧪 Testing database...")
        
        running_jobs = self.get_running_jobs()
        if not running_jobs:
            print("⚠️  No running database job found")
            return False
        
        # Start test job
        returncode, stdout, stderr = self.run_command(f"sbatch {self.test_script}")
        if returncode == 0:
            test_job_id = stdout.strip().split()[-1]
            print(f"✅ Test job started: {test_job_id}")
            print("⏳ Waiting 15 seconds for test result...")
            time.sleep(15)
            
            # Check test result
            log_file = f"slurm-{test_job_id}.out"
            if os.path.exists(os.path.join(self.script_dir, log_file)):
                with open(os.path.join(self.script_dir, log_file), 'r') as f:
                    content = f.read()
                    if "✅ Database connection successful!" in content:
                        print("✅ Database test successful!")
                        return True
                    else:
                        print("❌ Database test failed!")
                        print("Test log:")
                        print(content)
                        return False
            else:
                print("⚠️  Test log file not found")
                return False
        else:
            print(f"❌ Failed to start test job: {stderr}")
            return False
    
    def status(self):
        """Check database status"""
        print("📊 Checking database status...")
        
        running_jobs = self.get_running_jobs()
        if running_jobs:
            print(f"✅ Database is running: {running_jobs[0]}")
            print("Job details:")
            self.run_command(f"squeue -j {running_jobs[0]}")
            return True
        else:
            print("❌ Database is not running")
            return False
    
    def interactive_mode(self):
        """Interactive mode"""
        print("🎮 Database Manager - Interactive Mode")
        print("Commands: start, stop, test, status, quit")
        
        while True:
            try:
                command = input("\n> ").strip().lower()
                
                if command == "start":
                    self.start_database()
                elif command == "stop":
                    self.stop_database()
                elif command == "test":
                    self.test_database()
                elif command == "status":
                    self.status()
                elif command in ["quit", "exit", "q"]:
                    print("👋 Exiting...")
                    break
                else:
                    print("❓ Invalid command. Available: start, stop, test, status, quit")
                    
            except KeyboardInterrupt:
                print("\n👋 Exiting...")
                break
            except Exception as e:
                print(f"❌ Error: {e}")

def main():
    if len(sys.argv) < 2:
        print("🎮 Database Manager - Interactive Mode")
        print("Commands: start, stop, test, status, quit")
        manager = DatabaseManager()
        manager.interactive_mode()
    else:
        command = sys.argv[1].lower()
        manager = DatabaseManager()
        
        if command == "start":
            manager.start_database()
        elif command == "stop":
            manager.stop_database()
        elif command == "test":
            manager.test_database()
        elif command == "status":
            manager.status()
        else:
            print("❓ Invalid command. Available: start, stop, test, status")
            print("Usage: python database_manager.py [start|stop|test|status]")

if __name__ == "__main__":
    main()
