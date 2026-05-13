# Bash Master Script - Quick Reference

## What It Does

The `run_regression.sh` bash script automates the entire regression testing workflow and organizes everything into a single timestamped folder.

**One command runs everything:**

```bash
./run_regression.sh
```

That's it! Everything else happens automatically.

## What Gets Created

Each time you run the script, it creates a new timestamped folder:

```
logs/regression_runs/
├── 20260513_000819/        ← First run (May 13, 2026 @ 00:08:19)
│   └── [test files]
│
└── 20260513_000902/        ← Latest run (May 13, 2026 @ 00:09:02)
    ├── regression_report.json        (Machine-readable results)
    ├── regression_summary.txt        (Human-readable results)
    ├── regression_history.jsonl      (Time-series data)
    ├── dashboard_output.txt          (Visual dashboard)
    ├── analysis_report.txt           (Trend analysis)
    ├── RUN_SUMMARY.txt               (Quick summary)
    ├── MANIFEST.json                 (File inventory)
    └── regression_test.log           (Debug log)
```

## Files Generated (Per Run)

### 1. regression_report.json

**Machine-readable test results**

- Average cycle time
- Median, min, max statistics
- All 30 test results with cycle counts
- Pass/fail status for each test

Example:

```json
{
  "statistics": {
    "average": 50.03,
    "median": 41.0,
    "min": 10,
    "max": 94,
    "total_cycles": 1501
  },
  "test_results": [
    {"test_number": 1, "cycles": 21, "status": "PASS"},
    ...
  ]
}
```

### 2. regression_summary.txt

**Human-readable test results**

- Full summary with statistics
- Detailed table of all 30 tests
- Pass/fail status

### 3. regression_history.jsonl

**Historical tracking (time-series)**

- One JSON line per regression run
- Accumulates over multiple runs
- Used for trend analysis and comparisons

### 4. dashboard_output.txt

**Visual dashboard report**

- Formatted summary
- All tests in grid layout
- Cycle time distribution chart
- Performance summary

### 5. analysis_report.txt

**Trend analysis results**

- Shows if performance is improving/regressing
- Detects anomalies
- Historical statistics

### 6. RUN_SUMMARY.txt

**Quick overview of this run**

- Key statistics
- List of all files in the folder
- Quick instructions

## Quick Start (3 Steps)

### Step 1: Run Baseline

```bash
./run_regression.sh
```

Completes in ~3 minutes. Creates first run folder with all results.

### Step 2: Make Code Changes

Edit your simulator code, then recompile:

```bash
gcc lc3bsim6.cpp -o lc3bsim6.exe
```

### Step 3: Run Tests Again

```bash
./run_regression.sh
```

Creates second run folder. Now you can compare.

## Viewing Results

### View Latest Run Summary

```bash
cat logs/regression_runs/20260513_000902/RUN_SUMMARY.txt
```

### View Dashboard

```bash
cat logs/regression_runs/20260513_000902/dashboard_output.txt
```

### View Raw JSON (for tools/scripts)

```bash
cat logs/regression_runs/20260513_000902/regression_report.json | python -m json.tool
```

### List All Runs

```bash
ls -lh logs/regression_runs/
```

### Compare Two Runs

```bash
python compare_regression.py auto
```

## Key Metrics

**Average Cycle Time** (from regression_report.json)

- **Good**: < 47.5 cycles (-5% improvement)
- **Acceptable**: 49.5 - 50.5 cycles (±1%)
- **Regression**: > 52.5 cycles (+5% slower)

**Baseline**: 50.03 cycles (30 tests combined)

## Complete Workflow Example

```bash
# Baseline run
./run_regression.sh
# Stores results in: logs/regression_runs/20260513_000902/

# Review baseline
cat logs/regression_runs/20260513_000902/RUN_SUMMARY.txt
# Shows: Average 50.03 cycles

# Make optimizations to simulator
vim lc3bsim6.cpp
gcc lc3bsim6.cpp -o lc3bsim6.exe

# Run tests again
./run_regression.sh
# Stores results in: logs/regression_runs/20260513_000930/

# Compare results
python compare_regression.py auto
# Shows: Average 48.50 cycles (-2.98% improvement!)

# Check if performance is consistently better
python analyze_regression.py
# Shows trend data
```

## What Each File Contains

| File                     | Size | Contains                      |
| ------------------------ | ---- | ----------------------------- |
| regression_report.json   | 2.9K | Full stats + all test results |
| regression_summary.txt   | 1.9K | Readable summary table        |
| regression_history.jsonl | 422B | One line per run              |
| dashboard_output.txt     | 5.5K | Visual dashboard              |
| analysis_report.txt      | 805B | Trend analysis                |
| RUN_SUMMARY.txt          | 2.9K | Quick overview                |
| MANIFEST.json            | 613B | File inventory                |
| regression_test.log      | 1.7K | Debug output                  |

## Troubleshooting

**Error: "lc3bsim6.exe not found"**

- Compile the simulator first: `gcc lc3bsim6.cpp -o lc3bsim6.exe`

**Error: "Test files not found"**

- Ensure all 30 test folders exist in `logs/Test1/` through `logs/Test30/`

**Script hangs**

- Kill with Ctrl+C
- Check `regression_test.log` for issues
- Verify simulator runs: `./lc3bsim6.exe ucode6 logs/Test1/test1.obj`

**Unicode errors**

- The script handles Windows encoding automatically
- If issues persist, run with: `PYTHONIOENCODING=utf-8 ./run_regression.sh`

## Tips & Tricks

### Automated Daily Runs (Linux/Mac)

Add to crontab:

```bash
0 2 * * * cd /path/to/TPU_Project && ./run_regression.sh
```

### Archive Old Runs

```bash
cd logs/regression_runs
mkdir archive
mv 20260513_* archive/  # Move old runs to archive folder
```

### Export Results

```bash
# Export JSON for analysis
cat logs/regression_runs/*/regression_report.json | python -m json.tool > all_results.json

# Export to CSV
python3 << 'EOF'
import json, csv
data = json.load(open('logs/regression_runs/20260513_000902/regression_report.json'))
with open('results.csv', 'w') as f:
    w = csv.writer(f)
    w.writerow(['Test', 'Cycles'])
    for r in data['test_results']:
        w.writerow([f"Test {r['test_number']}", r['cycles']])
EOF
```

### Compare Specific Runs Manually

```bash
# Get average from run 1
cat logs/regression_runs/20260513_000819/regression_report.json | grep average

# Get average from run 2
cat logs/regression_runs/20260513_000902/regression_report.json | grep average

# Calculate percent change
python3 -c "print(f'{((48.5 - 50.03) / 50.03 * 100):.2f}%')"
```

## Advanced: Running Multiple Times

```bash
# Run 5 times and collect results
for i in {1..5}; do
    echo "Run $i..."
    ./run_regression.sh
    sleep 5  # Wait between runs
done

# Now analyze
python analyze_regression.py
```

---

**TL;DR:**

```bash
./run_regression.sh        # Run everything (creates timestamped folder)
cat logs/regression_runs/*/RUN_SUMMARY.txt  # View latest results
```

That's it! Every run creates a complete, organized folder with all results.
