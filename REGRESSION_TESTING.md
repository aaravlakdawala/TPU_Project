# LC-3b Simulator - Regression Testing Framework

## Overview

This regression testing framework automatically runs all 30 test cases and generates comprehensive performance metrics. It's designed to track performance changes over time and detect performance regressions.

## Features

✓ **Automated Testing** - Runs all 30 tests automatically  
✓ **Cycle Time Tracking** - Captures cycle counts for each test  
✓ **Statistical Analysis** - Calculates average, median, min/max, std dev  
✓ **Historical Tracking** - Maintains history for trend analysis  
✓ **Anomaly Detection** - Detects performance outliers  
✓ **Trend Analysis** - Identifies performance improvements/regressions  
✓ **Multiple Report Formats** - JSON (machine-readable) and TXT (human-readable)

## Quick Start

### 1. Run Full Regression Test

```bash
python regression_test.py
```

This will:

- Run all 30 tests (Test1 through Test30)
- Extract cycle counts from each test
- Calculate statistics (average, median, range, std dev)
- Generate reports in `./logs/regression/`

### 2. View Analysis & Trends

```bash
python analyze_regression.py
```

This will display:

- Latest run results
- Performance trends (improvement vs regression)
- Anomaly detection alerts
- Historical statistics

## Output Files

### Location: `./logs/regression/`

**1. `regression_report.json`** (Machine-readable)

```json
{
  "timestamp": "2026-05-13T00:04:02.866531",
  "num_tests": 30,
  "statistics": {
    "average": 50.03,
    "median": 41.00,
    "min": 10,
    "max": 94,
    "std_dev": 28.99,
    "total_tests": 30,
    "passed_tests": 30,
    "failed_tests": 0
  },
  "test_results": [
    {"test_number": 1, "cycles": 21, "status": "PASS"},
    ...
  ]
}
```

**2. `regression_summary.txt`** (Human-readable)

- Full test results table
- Summary statistics
- Pass/fail counts

**3. `regression_history.jsonl`** (Time-series data)

- One JSON line per regression run
- Used for trend analysis
- Grows with each regression run

## Performance Metrics Explained

| Metric           | Definition                        |
| ---------------- | --------------------------------- |
| **Average**      | Mean cycle count across all tests |
| **Median**       | Middle value when sorted          |
| **Min/Max**      | Fastest/slowest test              |
| **Std Dev**      | Measure of consistency            |
| **Total Cycles** | Sum of all cycles (all tests)     |

## Interpreting Results

### Example Output

```
Average:  50.03 cycles
Median:   41.00 cycles
Range:    10 - 94 cycles
Std Dev:  28.99 cycles
```

**What this means:**

- Most tests complete in ~50 cycles
- Half of tests finish before 41 cycles
- Test times vary from 10 to 94 cycles
- High std dev (28.99) indicates variable test complexity

## Trend Analysis

After running multiple regression tests, the analysis shows:

```
📈 REGRESSION (slower)      <- Performance got worse
  Change: +5.23%
📉 IMPROVEMENT (faster)     <- Performance got better
  Change: -3.47%
```

## Regression Workflow

1. **Baseline Run** (First time)

   ```bash
   python regression_test.py
   ```

   Creates initial baseline metrics

2. **Make Changes** to simulator code

3. **Regression Run** (After changes)

   ```bash
   python regression_test.py
   ```

   Compares against previous baseline

4. **Analyze Results**
   ```bash
   python analyze_regression.py
   ```
   Automatically detects regressions

## Advanced Usage

### Create a Cron Job (Linux/Mac)

```bash
# Run regression tests daily at 2 AM
0 2 * * * cd /path/to/TPU_Project && python regression_test.py
```

### Create a Scheduled Task (Windows)

```powershell
# PowerShell
$trigger = New-ScheduledTaskTrigger -Daily -At 2am
$action = New-ScheduledTaskAction -Execute "python.exe" -Argument "regression_test.py" -WorkingDirectory "C:\Users\aarav\TPU_Project"
Register-ScheduledTask -TaskName "LC3b_Regression" -Trigger $trigger -Action $action
```

### Generate CSV for Spreadsheet

```python
import csv
import json

with open('./logs/regression/regression_report.json') as f:
    data = json.load(f)

with open('./logs/regression/results.csv', 'w', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(['Test', 'Cycles', 'Status'])
    for result in data['test_results']:
        writer.writerow([f"Test {result['test_number']}", result['cycles'], result['status']])
```

## Understanding Variability

Tests may have different cycle counts due to:

1. **Cache Misses** - Data/instruction cache hits/misses
2. **Pipeline Stalls** - Branch stalls, data dependencies
3. **Memory Access** - Load/store latency
4. **Test Complexity** - Number of instructions in test

High std deviation is normal and expected.

## Troubleshooting

### Error: "Program file not found"

```
❌ Test 5: Program file not found at ./logs/Test5/test5.obj
```

**Solution:** Ensure all test files are compiled (test1.obj through test30.obj)

### Error: "Could not extract cycle count"

```
⚠ Test 10: Could not extract cycle count
```

**Solution:** Check if simulator is producing output; verify `lc3bsim6.exe` is built

### No regression history

```
⚠ No regression history found. Run regression_test.py first.
```

**Solution:** Run `python regression_test.py` before running analysis

## Performance Targets

Use these as baseline references:

| Category          | Cycles |
| ----------------- | ------ |
| Simple arithmetic | 10-25  |
| With branches     | 20-50  |
| Memory operations | 40-60  |
| Complex sequences | 80-94  |

## Next Steps

1. **Run regression tests regularly** to catch performance changes
2. **Compare against baseline** to identify slowdowns
3. **Track improvements** over code optimizations
4. **Archive results** for long-term trend analysis

---

**Created:** 2026-05-13  
**Framework Version:** 1.0
