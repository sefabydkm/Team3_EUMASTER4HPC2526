# Logs Directory

This directory contains execution logs and results from MeluXina examples and benchmarking runs.

## Structure

```
logs/
├── examples/
│   ├── user1/           # Individual user example runs
│   ├── user2/
│   └── ...
├── benchmarks/          # Benchmark execution logs
├── monitoring/          # System monitoring outputs
└── analysis/           # Log analysis and summaries
```

## Phase 1 Requirements

Each team member must:
1. Run the provided MeluXina examples
2. Collect complete execution logs
3. Document system resource usage
4. Upload results to their respective user directory

## Log Format Guidelines

- Include timestamps for all executions
- Capture both stdout and stderr
- Document job submission parameters
- Include resource usage statistics (CPU, memory, GPU)
- Add brief analysis or observations for each run

## Example Log Structure

Each user directory should contain:
- `job-submission.log` - Slurm job submission details
- `execution.log` - Application output
- `resource-usage.log` - System resource monitoring
- `summary.md` - Brief analysis and findings