#!/usr/bin/env python3
"""
Regression Testing Framework for LC-3b Simulator
Runs all 30 tests and generates performance metrics
"""

import subprocess
import re
import os
import json
import statistics
from datetime import datetime
from pathlib import Path

# Configuration
SIM = "./lc3bsim6.exe"
UCODE = "ucode6"
NUM_TESTS = 30
MAX_CYCLES = 94
REGRESSION_FOLDER = "./logs/regression"
REGRESSION_REPORT = "regression_report.json"
REGRESSION_SUMMARY = "regression_summary.txt"


def ensure_regression_folder():
    """Create regression folder if it doesn't exist"""
    Path(REGRESSION_FOLDER).mkdir(parents=True, exist_ok=True)


def run_single_test(test_num):
    """Run a single test and extract cycle count"""
    test_folder = f"./logs/Test{test_num}"
    program = f"{test_folder}/test{test_num}.obj"

    if not os.path.exists(program):
        print(f"❌ Test {test_num}: Program file not found at {program}")
        return None

    try:
        # Build commands for simulation
        cmds = "idump\n" + \
            "".join("run 1\nidump\n" for _ in range(MAX_CYCLES)) + "quit\n"

        # Run simulator
        proc = subprocess.Popen(
            [SIM, UCODE, program],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            shell=False
        )
        stdout, _ = proc.communicate(input=cmds, timeout=30)

        # Extract cycle count
        cycle_counts = re.findall(r'Cycle Count\s*:\s*(\d+)', stdout)

        if cycle_counts:
            # Get the final cycle count
            final_cycle = int(cycle_counts[-1])
            print(f"[PASS] Test {test_num:2d}: {final_cycle:3d} cycles")
            return final_cycle
        else:
            print(f"[WARN] Test {test_num}: Could not extract cycle count")
            return None

    except subprocess.TimeoutExpired:
        print(f"[FAIL] Test {test_num}: Timeout")
        return None
    except Exception as e:
        print(f"[FAIL] Test {test_num}: Error - {e}")
        return None


def calculate_statistics(cycle_times):
    """Calculate statistics from cycle times"""
    valid_times = [t for t in cycle_times if t is not None]

    if not valid_times:
        return None

    stats = {
        "total_tests": len(cycle_times),
        "passed_tests": len(valid_times),
        "failed_tests": len(cycle_times) - len(valid_times),
        "average": statistics.mean(valid_times),
        "median": statistics.median(valid_times),
        "min": min(valid_times),
        "max": max(valid_times),
        "std_dev": statistics.stdev(valid_times) if len(valid_times) > 1 else 0,
        "total_cycles": sum(valid_times)
    }
    return stats


def run_regression_tests():
    """Run all regression tests"""
    print("\n" + "="*60)
    print("LC-3b Simulator Regression Testing Framework")
    print(f"Running {NUM_TESTS} test cases...")
    print("="*60 + "\n")

    ensure_regression_folder()

    cycle_times = []
    test_results = []

    for test_num in range(1, NUM_TESTS + 1):
        cycles = run_single_test(test_num)
        cycle_times.append(cycles)
        test_results.append({
            "test_number": test_num,
            "cycles": cycles,
            "status": "PASS" if cycles is not None else "FAIL"
        })

    stats = calculate_statistics(cycle_times)

    # Generate report data
    report_data = {
        "timestamp": datetime.now().isoformat(),
        "num_tests": NUM_TESTS,
        "statistics": stats,
        "test_results": test_results
    }

    return report_data


def save_json_report(report_data):
    """Save detailed report as JSON"""
    report_path = f"{REGRESSION_FOLDER}/{REGRESSION_REPORT}"
    with open(report_path, 'w') as f:
        json.dump(report_data, f, indent=2)
    return report_path


def save_summary_report(report_data):
    """Save human-readable summary"""
    stats = report_data["statistics"]
    summary_path = f"{REGRESSION_FOLDER}/{REGRESSION_SUMMARY}"

    with open(summary_path, 'w') as f:
        f.write("="*70 + "\n")
        f.write("LC-3b SIMULATOR REGRESSION TEST REPORT\n")
        f.write("="*70 + "\n\n")

        f.write(f"Timestamp: {report_data['timestamp']}\n")
        f.write(f"Total Tests Run: {stats['total_tests']}\n")
        f.write(f"Passed: {stats['passed_tests']}\n")
        f.write(f"Failed: {stats['failed_tests']}\n")
        f.write(
            f"Success Rate: {(stats['passed_tests']/stats['total_tests']*100):.1f}%\n\n")

        f.write("CYCLE TIME STATISTICS\n")
        f.write("-"*70 + "\n")
        f.write(f"Average Cycle Time:  {stats['average']:.2f} cycles\n")
        f.write(f"Median Cycle Time:   {stats['median']:.2f} cycles\n")
        f.write(f"Minimum Cycle Time:  {stats['min']} cycles\n")
        f.write(f"Maximum Cycle Time:  {stats['max']} cycles\n")
        f.write(f"Std Deviation:       {stats['std_dev']:.2f} cycles\n")
        f.write(f"Total Cycles (All):  {stats['total_cycles']} cycles\n\n")

        f.write("DETAILED RESULTS\n")
        f.write("-"*70 + "\n")
        f.write(f"{'Test':<8} {'Cycles':<12} {'Status':<10}\n")
        f.write("-"*70 + "\n")

        for result in report_data["test_results"]:
            cycles_str = str(
                result["cycles"]) if result["cycles"] is not None else "N/A"
            f.write(
                f"Test {result['test_number']:<2} {cycles_str:<12} {result['status']:<10}\n")

        f.write("\n" + "="*70 + "\n")

    return summary_path


def append_to_regression_history(report_data):
    """Append results to regression history for trend tracking"""
    history_path = f"{REGRESSION_FOLDER}/regression_history.jsonl"

    history_entry = {
        "timestamp": report_data["timestamp"],
        "average_cycles": report_data["statistics"]["average"],
        "median_cycles": report_data["statistics"]["median"],
        "min_cycles": report_data["statistics"]["min"],
        "max_cycles": report_data["statistics"]["max"],
        "std_dev": report_data["statistics"]["std_dev"],
        "passed_tests": report_data["statistics"]["passed_tests"],
        "failed_tests": report_data["statistics"]["failed_tests"]
    }

    with open(history_path, 'a') as f:
        json.dump(history_entry, f)
        f.write("\n")

    return history_path


def display_summary(report_data):
    """Display summary to console"""
    stats = report_data["statistics"]

    print("\n" + "="*60)
    print("REGRESSION TEST SUMMARY")
    print("="*60)
    print(f"Tests Passed: {stats['passed_tests']}/{stats['total_tests']}")
    print(
        f"Success Rate: {(stats['passed_tests']/stats['total_tests']*100):.1f}%\n")

    print("CYCLE TIME METRICS:")
    print(f"  Average:  {stats['average']:.2f} cycles")
    print(f"  Median:   {stats['median']:.2f} cycles")
    print(f"  Range:    {stats['min']} - {stats['max']} cycles")
    print(f"  Std Dev:  {stats['std_dev']:.2f} cycles")
    print("="*60 + "\n")


if __name__ == "__main__":
    # Run all tests
    report_data = run_regression_tests()

    # Save reports
    json_path = save_json_report(report_data)
    summary_path = save_summary_report(report_data)
    history_path = append_to_regression_history(report_data)

    # Display summary
    display_summary(report_data)

    print("[REPORT] Reports generated:")
    print(f"   JSON Report:   {json_path}")
    print(f"   Summary Report: {summary_path}")
    print(f"   History File:   {history_path}")
    print()
