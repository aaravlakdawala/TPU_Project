# LC-3b Simulator - Regression Testing Setup Complete ✓

## 🎉 What's Been Created

Your regression testing framework is now fully set up! Here's what you have:

### 📊 Main Testing Scripts

| Script                  | Purpose                             | Usage                          |
| ----------------------- | ----------------------------------- | ------------------------------ |
| `regression_test.py`    | Run all 30 tests & generate metrics | `python regression_test.py`    |
| `dashboard.py`          | Visual summary of latest results    | `python dashboard.py`          |
| `analyze_regression.py` | Trend analysis & anomaly detection  | `python analyze_regression.py` |
| `compare_regression.py` | Compare results between runs        | `python compare_regression.py` |

### 📚 Documentation

| Document                    | Focus                    |
| --------------------------- | ------------------------ |
| `REGRESSION_QUICK_START.md` | 5-minute quick reference |
| `REGRESSION_TESTING.md`     | Complete detailed guide  |

### 📁 Data Storage

**Location**: `./logs/regression/`

Files generated automatically:

- `regression_report.json` - Detailed metrics (JSON format)
- `regression_summary.txt` - Human-readable report
- `regression_history.jsonl` - Time-series history (one entry per run)

## 🚀 Getting Started (5 Minutes)

### Step 1: Run Baseline (Now)

```bash
python regression_test.py
```

Output:

```
✓ Test  1:  21 cycles
✓ Test  2:  48 cycles
...
✓ Test 30:  10 cycles

Average:  50.03 cycles
Median:   41.00 cycles
Range:    10 - 94 cycles
Std Dev:  28.99 cycles
```

**This is your baseline!** Record this somewhere for reference.

### Step 2: View Dashboard

```bash
python dashboard.py
```

Shows visual representation of all results with charts.

### Step 3: Make Code Changes

Modify your simulator code (e.g., optimize cache, improve pipeline, etc.)

### Step 4: Test Again

```bash
python regression_test.py
```

Compare the new average to your baseline:

- **Lower average** = IMPROVEMENT ✓
- **Higher average** = REGRESSION ⚠
- **Same average** = NO CHANGE →

### Step 5: Analyze Trends

```bash
python analyze_regression.py
```

See if changes improve or regress performance.

## 📊 Key Metrics Explained

### Average Cycle Time (Primary Metric)

- **What it is**: Mean cycles across all 30 tests
- **Why it matters**: Overall performance indicator
- **Target**: Lower is better

### Baseline: 50.03 cycles

- **Good improvement**: < 47.5 cycles (-5%)
- **Minor improvement**: 47.5 - 49.5 cycles (-1 to -5%)
- **Acceptable**: 49.5 - 50.5 cycles (±1%)
- **Minor regression**: 50.5 - 52.5 cycles (+1 to +5%)
- **Bad regression**: > 52.5 cycles (+5%)

### Example Results

**Scenario A: Improvement** ✓

```
Baseline:    50.03 cycles
After fix:   48.50 cycles
Change:      -2.98% (GOOD!)
```

**Scenario B: Regression** ⚠

```
Baseline:    50.03 cycles
After fix:   52.10 cycles
Change:      +5.23% (BAD - investigate)
```

## 📈 Using for Regression Testing

### Workflow Example

```
Week 1: Establish Baseline
├─ Day 1: python regression_test.py
│         Result: 50.03 cycles (BASELINE)
└─ Dashboard stored for reference

Week 2: Test Optimization
├─ Day 2: Optimize cache → python regression_test.py
│         Result: 48.50 cycles (-2.98% ✓)
├─ Day 3: Optimize pipeline → python regression_test.py
│         Result: 47.20 cycles (-5.67% ✓✓)
└─ python analyze_regression.py
   Shows consistent improvement trend

Week 3: Experimental Change
├─ Day 4: Try branch predictor → python regression_test.py
│         Result: 52.10 cycles (+5.23% ⚠)
├─ python compare_regression.py auto
│         Shows regression vs previous
└─ REVERT changes, go back to Day 3 baseline
```

## 🔍 Interpreting Dashboard Output

```
CYCLE TIME METRICS:
  Average:        50.03 cycles   ← Main metric to track
  Median:         41.00 cycles   ← Half finish faster
  Range:        10 - 94 cycles   ← Min to max variation
  Std Deviation:  28.99 cycles   ← Spread across tests
  Total Cycles:    1501           ← Sum of all 30 tests
```

## 💾 Data Storage & History

Each time you run `regression_test.py`, a new entry is added to:

- `regression_history.jsonl` - One JSON line per run

This allows you to:

- ✓ Track performance over weeks/months
- ✓ Detect trends (improving vs getting worse)
- ✓ Compare against all previous runs
- ✓ Generate performance reports

Example history (3 runs):

```json
{"timestamp": "2026-05-13T00:04", "average_cycles": 50.03, ...}
{"timestamp": "2026-05-14T08:30", "average_cycles": 48.50, ...}
{"timestamp": "2026-05-15T14:15", "average_cycles": 47.20, ...}
```

## 🎯 Common Tasks

### Track Performance Over Time

```bash
# Daily baseline check
python regression_test.py

# Weekly trend analysis
python analyze_regression.py

# See what's changed since yesterday
python compare_regression.py auto
```

### Debug a Regression

```bash
python dashboard.py          # Identify slow tests
python compare_regression.py # Compare with baseline
```

### Archive Baseline Before Major Changes

```bash
# Save current results
cp logs/regression/regression_history.jsonl logs/regression/baseline_before_refactor.jsonl

# Make major changes...

# Run tests
python regression_test.py

# Compare
python compare_regression.py
```

## 📝 Next Steps

1. **Run baseline now**
   ```bash
   python regression_test.py
   ```
2. **Review the dashboard**
   ```bash
   python dashboard.py
   ```
3. **Save these docs** for reference

4. **Start tracking** after each code change

5. **Set performance goals** (e.g., keep average < 52 cycles)

## 🚨 Important Notes

- **First run creates baseline** - All subsequent runs compare to this
- **1501 total cycles** - Sum of all 30 tests (can be used as secondary metric)
- **Variance is normal** - Tests have different complexity (10-94 cycles range)
- **Historical data saved** - Automatically accumulates for trend analysis
- **Compare runs anytime** - Use `compare_regression.py` to see what changed

## ❓ FAQ

**Q: Can I run just some tests?**  
A: Current setup runs all 30. To run subset, modify `NUM_TESTS = 30` in `regression_test.py`

**Q: How often should I run tests?**  
A: After each significant code change, or daily for continuous monitoring

**Q: Can I reset the history?**  
A: Yes, delete `logs/regression/regression_history.jsonl` (but saves history first!)

**Q: What if cycle times vary between runs?**  
A: This is expected due to cache behavior and system load. Use average trend, not single values.

**Q: How do I know if a change is "good" or "bad"?**  
A: Use 1% threshold: ±0.5 cycles is noise, >1% change is significant

---

**Setup Date**: 2026-05-13  
**Total Tests**: 30  
**Baseline Average**: 50.03 cycles  
**Baseline Status**: ✓ ESTABLISHED

---

### Quick Command Reference

```bash
python regression_test.py    # Run all tests
python dashboard.py          # View results
python analyze_regression.py # See trends
python compare_regression.py # Compare runs
```

**You're all set! Happy testing! 🎉**
