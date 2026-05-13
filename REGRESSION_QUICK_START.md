# Regression Testing - Quick Reference Guide

## 📊 Overview

All 30 test cases now run together and generate comprehensive performance metrics. Results are stored in a single regression folder for tracking performance over time.

## 🚀 Quick Commands

```bash
# Run regression tests (all 30 tests)
python regression_test.py

# View dashboard (visual summary)
python dashboard.py

# Analyze trends (performance changes)
python analyze_regression.py

# Compare runs (see what changed between runs)
python compare_regression.py

# Compare specific runs
python compare_regression.py all      # Show all runs first
python compare_regression.py auto     # Auto-compare latest 2 runs
```

## 📁 Output Files Location

All results stored in: **`./logs/regression/`**

| File                       | Purpose                         | Format                  |
| -------------------------- | ------------------------------- | ----------------------- |
| `regression_report.json`   | Latest detailed results         | JSON (machine-readable) |
| `regression_summary.txt`   | Latest results summary          | Text (human-readable)   |
| `regression_history.jsonl` | All runs history (one per line) | JSONL (time-series)     |

## 📈 Workflow Example

```
Day 1: Initial Baseline
└─> python regression_test.py
    Average: 50.03 cycles (BASELINE)

Day 2: After code changes
└─> python regression_test.py
    Average: 48.50 cycles (-2.98% IMPROVEMENT ✓)

Day 3: Another optimization attempt
└─> python regression_test.py
    Average: 52.10 cycles (+5.23% REGRESSION ⚠)
    └─> python analyze_regression.py  (shows anomaly)
    └─> python compare_regression.py   (compare with day 1)
```

## 🎯 Key Metrics

**Average Cycle Time**: The primary metric tracking overall performance

- Lower is better
- Compare across runs to detect regressions

**Std Deviation**: Consistency across tests

- High variability = some tests are much slower
- Indicates different test complexity levels

**Min/Max Range**: Performance spread

- Identifies fastest/slowest tests
- Large range is normal (test complexity varies)

## 📊 Interpreting Results

```
CYCLE TIME METRICS:
  Average:  50.03 cycles     ← Primary metric
  Median:   41.00 cycles     ← Half of tests faster/slower
  Range:    10 - 94 cycles   ← Fastest to slowest
  Std Dev:  28.99 cycles     ← Variation across tests
```

## 🔍 Common Scenarios

### Scenario 1: Performance Improvement

```
Run 1: 50.03 cycles average
Run 2: 48.50 cycles average
       Improvement: 2.98% (GOOD!)
```

✓ Changes are working  
✓ Keep the changes  
✓ Make it your new baseline

### Scenario 2: Performance Regression

```
Run 1: 50.03 cycles average
Run 2: 52.10 cycles average
       Regression: 5.23% (BAD!)
```

⚠ Changes made things slower  
❌ Need to investigate  
❌ Consider reverting

### Scenario 3: Anomaly Detected

```
Run 1: 50.03 cycles average (normal)
Run 2: 72.45 cycles average (spike!)
```

⚠ Something unusual happened  
→ Check for one slow test  
→ Use dashboard to identify it

## 📋 Test Coverage

- **Tests**: 30 test cases (Test1 through Test30)
- **Location**: `./logs/Test1/` through `./logs/Test30/`
- **Total Cycles**: Sum of all test cycles (baseline: 1501)
- **Success Rate**: 100% if all tests pass (30/30)

## 🛠️ Troubleshooting

| Issue                      | Solution                                             |
| -------------------------- | ---------------------------------------------------- |
| Tests fail to run          | Ensure `lc3bsim6.exe` is compiled                    |
| Can't find test files      | Check `./logs/Test1/` through `./logs/Test30/` exist |
| Dashboard shows nothing    | Run `python regression_test.py` first                |
| Compare tool shows nothing | Need at least 2 regression runs                      |
| Very different cycle times | Normal - tests have different complexity             |

## 💡 Pro Tips

1. **Establish Baseline First**

   ```bash
   python regression_test.py  # Run 1
   python dashboard.py        # Record baseline
   ```

2. **Make Changes Incrementally**
   - Change one thing at a time
   - Run regression test after each change
   - Use compare tool to see impact

3. **Automated Tracking**
   - Save regression history regularly
   - Archive old reports (especially before major changes)
   - Track which commits caused regressions

4. **Performance Targets**
   - Simple ops: 10-20 cycles
   - With branches: 30-50 cycles
   - Complex sequences: 80-94 cycles

## 📚 Detailed Documentation

For full documentation, see: **REGRESSION_TESTING.md**

---

**Last Updated:** 2026-05-13  
**Test Count:** 30  
**Version:** 1.0
