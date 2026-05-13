#!/usr/bin/env python3
"""
Comparison Tool - Compare regression results between runs
"""

import json
import statistics
from pathlib import Path

REGRESSION_FOLDER = "./logs/regression"
HISTORY_FILE = f"{REGRESSION_FOLDER}/regression_history.jsonl"
REPORT_FILE = f"{REGRESSION_FOLDER}/regression_report.json"


def load_history():
    """Load regression history"""
    if not Path(HISTORY_FILE).exists():
        print("⚠ No regression history found.")
        return []

    history = []
    with open(HISTORY_FILE, 'r') as f:
        for line in f:
            if line.strip():
                history.append(json.loads(line))

    return history


def load_current_report():
    """Load current regression report"""
    if not Path(REPORT_FILE).exists():
        return None

    with open(REPORT_FILE, 'r') as f:
        return json.load(f)


def compare_runs(history_index=-2):
    """Compare two runs from history"""
    history = load_history()

    if len(history) < 2:
        print("❌ Need at least 2 regression runs to compare.")
        print(f"   Currently have: {len(history)} run(s)")
        return

    # Get the two runs to compare
    if history_index < -len(history):
        print(f"❌ Invalid run index. History has {len(history)} runs.")
        return

    run1 = history[history_index]
    run2 = history[-1]  # Latest run

    print("\n" + "="*80)
    print("REGRESSION RUN COMPARISON")
    print("="*80)

    print(f"\n📊 Run 1: {run1['timestamp']}")
    print(f"📊 Run 2: {run2['timestamp']} (Latest)")
    print()

    # Compare metrics
    metrics = [
        ("Average Cycles", "average_cycles"),
        ("Median Cycles", "median_cycles"),
        ("Min Cycles", "min_cycles"),
        ("Max Cycles", "max_cycles"),
        ("Std Deviation", "std_dev"),
        ("Tests Passed", "passed_tests"),
        ("Tests Failed", "failed_tests")
    ]

    print("┌─ METRIC COMPARISON " + "─"*59 + "┐")
    print(f"{'Metric':<20} {'Run 1':<15} {'Run 2':<15} {'Change':<15}")
    print("├" + "─"*20 + "┼" + "─"*15 + "┼" + "─"*15 + "┼" + "─"*15 + "┤")

    for name, key in metrics:
        val1 = run1.get(key, 0)
        val2 = run2.get(key, 0)

        # Format values
        if isinstance(val1, float):
            v1_str = f"{val1:.2f}"
            v2_str = f"{val2:.2f}"
        else:
            v1_str = str(val1)
            v2_str = str(val2)

        # Calculate change
        if val1 != 0:
            change = val2 - val1
            if isinstance(change, float):
                change_pct = (change / val1) * 100
                change_str = f"{change:+.2f} ({change_pct:+.1f}%)"
            else:
                change_str = f"{change:+d}"

            # Determine direction
            if "Failed" in name or "Max" in name or "Std" in name:
                direction = "🔴" if change > 0 else "🟢"
            else:
                direction = "🔴" if change > 0 else "🟢"
        else:
            change_str = "N/A"
            direction = " "

        print(f"{name:<20} {v1_str:<15} {v2_str:<15} {direction} {change_str:<14}")

    print("└" + "─"*80 + "┘")

    # Interpretation
    print("\n📈 INTERPRETATION:")

    if run2["average_cycles"] < run1["average_cycles"]:
        improvement = ((run1["average_cycles"] - run2["average_cycles"]) /
                       run1["average_cycles"] * 100)
        print(f"✓ IMPROVEMENT: Average cycles decreased by {improvement:.1f}%")
    elif run2["average_cycles"] > run1["average_cycles"]:
        regression = ((run2["average_cycles"] - run1["average_cycles"]) /
                      run1["average_cycles"] * 100)
        print(f"⚠ REGRESSION: Average cycles increased by {regression:.1f}%")
    else:
        print("→ STABLE: No change in average cycles")

    if run2["failed_tests"] > run1["failed_tests"]:
        print(
            f"⚠ More tests failing: {run1['failed_tests']} → {run2['failed_tests']}")
    elif run2["failed_tests"] < run1["failed_tests"]:
        print(
            f"✓ Fewer test failures: {run1['failed_tests']} → {run2['failed_tests']}")

    print("\n" + "="*80 + "\n")


def show_all_runs():
    """Display all regression runs in history"""
    history = load_history()

    if not history:
        print("❌ No regression history found.")
        return

    print("\n" + "="*80)
    print("REGRESSION HISTORY - ALL RUNS")
    print("="*80 + "\n")

    print(f"{'Run':<5} {'Timestamp':<25} {'Avg':<8} {'Median':<8} {'Pass':<6} {'Fail':<6}")
    print("-"*80)

    for i, run in enumerate(history, 1):
        timestamp = run['timestamp'][:19]  # Just the date/time part
        avg = f"{run['average_cycles']:.1f}"
        median = f"{run['median_cycles']:.1f}"
        passed = run['passed_tests']
        failed = run['failed_tests']

        print(f"{i:<5} {timestamp:<25} {avg:<8} {median:<8} {passed:<6} {failed:<6}")

    print("\n" + "="*80 + "\n")


def interactive_compare():
    """Interactive comparison tool"""
    history = load_history()

    if len(history) < 2:
        print("❌ Need at least 2 regression runs to compare.")
        print(f"   Currently have: {len(history)} run(s)")
        print("   Run 'python regression_test.py' to generate runs.")
        return

    while True:
        print("\nComparison Options:")
        print("1. Compare latest 2 runs (default)")
        print("2. Compare specific runs")
        print("3. Show all runs in history")
        print("4. Exit")

        choice = input("\nEnter choice (1-4): ").strip()

        if choice == "1" or choice == "":
            compare_runs(-2)
        elif choice == "2":
            show_all_runs()
            try:
                idx = int(input("Enter first run number (1-indexed): ")) - 1
                compare_runs(idx - len(history))
            except ValueError:
                print("Invalid input")
        elif choice == "3":
            show_all_runs()
        elif choice == "4":
            break
        else:
            print("Invalid choice")


if __name__ == "__main__":
    import sys

    if len(sys.argv) > 1 and sys.argv[1] == "auto":
        # Auto-compare latest two runs
        compare_runs(-2)
    elif len(sys.argv) > 1 and sys.argv[1] == "all":
        # Show all runs
        show_all_runs()
    else:
        # Interactive mode
        interactive_compare()
