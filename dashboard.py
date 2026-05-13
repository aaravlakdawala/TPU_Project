#!/usr/bin/env python3
"""
Dashboard Viewer - Quick view of latest regression results
"""

import json
import os
from pathlib import Path
from datetime import datetime

REGRESSION_FOLDER = "./logs/regression"
REPORT_FILE = f"{REGRESSION_FOLDER}/regression_report.json"


def load_latest_report():
    """Load the latest regression report"""
    if not Path(REPORT_FILE).exists():
        print("❌ No regression report found. Run 'python regression_test.py' first.")
        return None

    with open(REPORT_FILE, 'r') as f:
        return json.load(f)


def display_dashboard():
    """Display dashboard view of latest results"""
    report = load_latest_report()
    if not report:
        return

    stats = report["statistics"]
    results = report["test_results"]

    # Clear screen (works on Windows and Unix)
    os.system('cls' if os.name == 'nt' else 'clear')

    # Header
    print("╔" + "═"*78 + "╗")
    print("║" + " "*20 + "LC-3b REGRESSION TEST DASHBOARD" + " "*28 + "║")
    print("╚" + "═"*78 + "╝")

    # Timestamp
    timestamp = datetime.fromisoformat(report["timestamp"])
    print(f"\n📅 Last Run: {timestamp.strftime('%Y-%m-%d %H:%M:%S')}\n")

    # Summary Box
    print("┌─ SUMMARY " + "─"*68 + "┐")
    print(f"│ Total Tests:     {stats['total_tests']:<3} │ Passed: {stats['passed_tests']:<3} │ Failed: {stats['failed_tests']:<3} │ "
          f"Success Rate: {(stats['passed_tests']/stats['total_tests']*100):>5.1f}%  │")
    print("└" + "─"*78 + "┘")

    # Metrics Box
    print("\n┌─ CYCLE TIME METRICS " + "─"*56 + "┐")
    print(
        f"│  Average:        {stats['average']:>7.2f} cycles                                    │")
    print(
        f"│  Median:         {stats['median']:>7.2f} cycles                                    │")
    print(
        f"│  Range:          {stats['min']:>3} - {stats['max']:<3} cycles (span: {stats['max']-stats['min']:<3})                      │")
    print(
        f"│  Std Deviation:  {stats['std_dev']:>7.2f} cycles                                    │")
    print(
        f"│  Total Cycles:   {stats['total_cycles']:>7} (all tests combined)                    │")
    print("└" + "─"*78 + "┘")

    # Results Grid
    print("\n┌─ DETAILED RESULTS " + "─"*58 + "┐")
    print("│ Test │ Cycles │ Status │  │ Test │ Cycles │ Status │  │ Test │ Cycles │ Status │")
    print("├──────┼────────┼────────┼──┼──────┼────────┼────────┼──┼──────┼────────┼────────┤")

    # Print in 3 columns
    for i in range(10):
        line = "│"

        # Column 1
        if i < len(results):
            r = results[i]
            cycles = f"{r['cycles']:>3}" if r['cycles'] else " N/A"
            status = "✓" if r['status'] == "PASS" else "✗"
            line += f" Test{r['test_number']:>2} │ {cycles:>6} │   {status}   │"
        else:
            line += " " * 24 + "│"

        line += "  │"

        # Column 2
        if i + 10 < len(results):
            r = results[i + 10]
            cycles = f"{r['cycles']:>3}" if r['cycles'] else " N/A"
            status = "✓" if r['status'] == "PASS" else "✗"
            line += f" Test{r['test_number']:>2} │ {cycles:>6} │   {status}   │"
        else:
            line += " " * 24 + "│"

        line += "  │"

        # Column 3
        if i + 20 < len(results):
            r = results[i + 20]
            cycles = f"{r['cycles']:>3}" if r['cycles'] else " N/A"
            status = "✓" if r['status'] == "PASS" else "✗"
            line += f" Test{r['test_number']:>2} │ {cycles:>6} │   {status}   │"
        else:
            line += " " * 24 + "│"

        print(line)

    print("└" + "─"*78 + "┘")

    # Performance Chart (ASCII histogram)
    print("\n┌─ CYCLE TIME DISTRIBUTION " + "─"*50 + "┐")

    # Categorize cycle times
    categories = {
        "10-20": 0, "21-30": 0, "31-40": 0,
        "41-50": 0, "51-60": 0, "61-70": 0,
        "71-80": 0, "81-90": 0, "91+": 0
    }

    for result in results:
        if result['cycles']:
            cycles = result['cycles']
            if cycles <= 20:
                categories["10-20"] += 1
            elif cycles <= 30:
                categories["21-30"] += 1
            elif cycles <= 40:
                categories["31-40"] += 1
            elif cycles <= 50:
                categories["41-50"] += 1
            elif cycles <= 60:
                categories["51-60"] += 1
            elif cycles <= 70:
                categories["61-70"] += 1
            elif cycles <= 80:
                categories["71-80"] += 1
            elif cycles <= 90:
                categories["81-90"] += 1
            else:
                categories["91+"] += 1

    max_count = max(categories.values()) if categories.values() else 1

    for range_label, count in categories.items():
        bar = "█" * int((count / max_count * 40) if max_count > 0 else 0)
        print(f"│ {range_label:>6} │ {bar:<40} │ {count:>2} tests │")

    print("└" + "─"*78 + "┘")

    # Footer
    print("\n" + "="*80)
    print("💡 TIP: Run 'python regression_test.py' to update results")
    print("        Run 'python analyze_regression.py' to view trends")
    print("="*80 + "\n")


if __name__ == "__main__":
    display_dashboard()
