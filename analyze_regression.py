#!/usr/bin/env python3
"""
Regression Analysis Tool - Analyze trends and detect performance changes
"""

import json
import statistics
from datetime import datetime
from pathlib import Path

REGRESSION_FOLDER = "./logs/regression"
HISTORY_FILE = f"{REGRESSION_FOLDER}/regression_history.jsonl"


def load_history():
    """Load regression history"""
    if not Path(HISTORY_FILE).exists():
        print("⚠ No regression history found. Run regression_test.py first.")
        return []

    history = []
    with open(HISTORY_FILE, 'r') as f:
        for line in f:
            if line.strip():
                history.append(json.loads(line))

    return history


def analyze_trends(history):
    """Analyze performance trends"""
    if len(history) < 2:
        print("⚠ Need at least 2 regression runs to analyze trends.")
        return None

    averages = [h["average_cycles"] for h in history]

    # Calculate trend
    first_half = statistics.mean(averages[:len(averages)//2])
    second_half = statistics.mean(averages[len(averages)//2:])

    trend = "📈 REGRESSION (slower)" if second_half > first_half else "📉 IMPROVEMENT (faster)"
    change_pct = ((second_half - first_half) / first_half * 100)

    return {
        "trend": trend,
        "change_percent": change_pct,
        "first_half_avg": first_half,
        "second_half_avg": second_half
    }


def detect_anomalies(history):
    """Detect anomalies in performance"""
    if len(history) < 3:
        return []

    averages = [h["average_cycles"] for h in history]
    mean_avg = statistics.mean(averages)
    std_dev = statistics.stdev(averages)
    threshold = mean_avg + (2 * std_dev)

    anomalies = []
    for i, entry in enumerate(history):
        if entry["average_cycles"] > threshold:
            anomalies.append({
                "run": i + 1,
                "average_cycles": entry["average_cycles"],
                "timestamp": entry["timestamp"],
                "deviation": entry["average_cycles"] - mean_avg
            })

    return anomalies


def display_analysis():
    """Display regression analysis"""
    history = load_history()

    if not history:
        return

    print("\n" + "="*70)
    print("REGRESSION ANALYSIS")
    print("="*70)

    print(f"\nTotal Regression Runs: {len(history)}\n")

    # Latest results
    latest = history[-1]
    print("LATEST RUN:")
    print(f"  Timestamp:      {latest['timestamp']}")
    print(f"  Average Cycles: {latest['average_cycles']:.2f}")
    print(f"  Median Cycles:  {latest['median_cycles']:.2f}")
    print(f"  Tests Passed:   {latest['passed_tests']}")
    print(f"  Tests Failed:   {latest['failed_tests']}\n")

    # Trend analysis
    if len(history) >= 2:
        trends = analyze_trends(history)
        print("TREND ANALYSIS:")
        print(f"  {trends['trend']}")
        print(f"  Change: {trends['change_percent']:+.2f}%")
        print(f"  First Half Avg:  {trends['first_half_avg']:.2f} cycles")
        print(f"  Second Half Avg: {trends['second_half_avg']:.2f} cycles\n")

    # Anomaly detection
    anomalies = detect_anomalies(history)
    if anomalies:
        print("⚠ PERFORMANCE ANOMALIES DETECTED:\n")
        for anom in anomalies:
            print(f"  Run {anom['run']}: {anom['average_cycles']:.2f} cycles")
            print(f"    (+{anom['deviation']:.2f} above average)")
            print(f"    Timestamp: {anom['timestamp']}\n")
    else:
        print("✓ No performance anomalies detected.\n")

    # Historical stats
    averages = [h["average_cycles"] for h in history]
    print("HISTORICAL STATISTICS (All Runs):")
    print(f"  Overall Average:  {statistics.mean(averages):.2f} cycles")
    print(f"  Overall Median:   {statistics.median(averages):.2f} cycles")
    print(f"  Best Run:         {min(averages):.2f} cycles")
    print(f"  Worst Run:        {max(averages):.2f} cycles")
    if len(averages) > 1:
        print(f"  Std Deviation:    {statistics.stdev(averages):.2f} cycles")
    else:
        print(f"  Std Deviation:    N/A (need multiple runs)")

    print("\n" + "="*70 + "\n")


if __name__ == "__main__":
    display_analysis()
