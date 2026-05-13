#!/bin/bash

################################################################################
#                                                                              #
#  LC-3b Simulator - Regression Testing Master Script                         #
#  Runs all 30 tests and organizes results into a timestamped folder          #
#                                                                              #
################################################################################

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUNS_FOLDER="${PROJECT_DIR}/logs/regression_runs"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
RUN_FOLDER="${RUNS_FOLDER}/${TIMESTAMP}"

# Create main runs folder if it doesn't exist
mkdir -p "${RUNS_FOLDER}"
mkdir -p "${RUN_FOLDER}"

################################################################################
# Helper Functions
################################################################################

print_header() {
    echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}  $1"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${YELLOW}ℹ${NC} $1"
}

################################################################################
# Main Script
################################################################################

print_header "LC-3b Regression Testing Master Script"

echo "Project Directory: ${PROJECT_DIR}"
echo "Run Folder: ${RUN_FOLDER}"
echo "Timestamp: ${TIMESTAMP}"
echo ""

# Check if necessary files exist
print_header "Checking Prerequisites"

if [ ! -f "${PROJECT_DIR}/lc3bsim6.exe" ]; then
    print_error "lc3bsim6.exe not found! Please compile first."
    exit 1
fi
print_success "Simulator found"

if [ ! -f "${PROJECT_DIR}/regression_test.py" ]; then
    print_error "regression_test.py not found!"
    exit 1
fi
print_success "Test runner found"

if [ ! -f "${PROJECT_DIR}/ucode6" ]; then
    print_error "ucode6 not found!"
    exit 1
fi
print_success "Microcode found"

# Check if Test folders exist
if [ ! -d "${PROJECT_DIR}/logs/Test1" ]; then
    print_error "Test folders not found!"
    exit 1
fi
print_success "Test files found"

# Run the regression tests
print_header "Running Regression Tests (30 tests)"

cd "${PROJECT_DIR}"
export PYTHONIOENCODING=utf-8
python regression_test.py > "${RUN_FOLDER}/regression_test.log" 2>&1

if [ $? -eq 0 ]; then
    print_success "Regression tests completed"
else
    print_error "Regression tests failed!"
    cat "${RUN_FOLDER}/regression_test.log"
    exit 1
fi

# Copy regression data to the run folder
print_header "Organizing Results"

if [ -d "${PROJECT_DIR}/logs/regression" ]; then
    cp -v "${PROJECT_DIR}/logs/regression/regression_report.json" "${RUN_FOLDER}/" 2>/dev/null && \
        print_success "Copied regression_report.json"
    
    cp -v "${PROJECT_DIR}/logs/regression/regression_summary.txt" "${RUN_FOLDER}/" 2>/dev/null && \
        print_success "Copied regression_summary.txt"
    
    cp -v "${PROJECT_DIR}/logs/regression/regression_history.jsonl" "${RUN_FOLDER}/" 2>/dev/null && \
        print_success "Copied regression_history.jsonl"
else
    print_error "Regression folder not found!"
fi

# Generate dashboard output
print_header "Generating Dashboard Report"

python dashboard.py > "${RUN_FOLDER}/dashboard_output.txt" 2>&1

if [ $? -eq 0 ]; then
    print_success "Dashboard report generated"
else
    print_info "Dashboard generation had issues (non-critical)"
fi

# Generate analysis report
print_header "Running Trend Analysis"

python analyze_regression.py > "${RUN_FOLDER}/analysis_report.txt" 2>&1

if [ $? -eq 0 ]; then
    print_success "Trend analysis completed"
else
    print_info "Analysis had issues (non-critical)"
fi

# Create a comprehensive summary report
print_header "Creating Summary Report"

cat > "${RUN_FOLDER}/RUN_SUMMARY.txt" << 'EOF'
╔════════════════════════════════════════════════════════════════════════════╗
║                  LC-3b REGRESSION TEST RUN SUMMARY                         ║
╚════════════════════════════════════════════════════════════════════════════╝

TIMESTAMP: $(date "+%Y-%m-%d %H:%M:%S")
FOLDER: $(basename "${RUN_FOLDER}")

FILES IN THIS FOLDER:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. regression_report.json
   Machine-readable test results with full statistics
   Contains: average cycles, median, min/max, all test results

2. regression_summary.txt
   Human-readable test results summary
   Contains: detailed results table, statistics, pass/fail info

3. regression_history.jsonl
   Historical tracking data (one JSON line per test run)
   Used by trend analysis tools

4. dashboard_output.txt
   Visual dashboard showing all test results
   Contains: summary, metrics, detailed results grid, distribution chart

5. analysis_report.txt
   Trend analysis and anomaly detection
   Contains: latest run info, trend direction, anomalies, historical stats

6. regression_test.log
   Raw output from regression_test.py
   Debug information if tests fail

7. RUN_SUMMARY.txt
   This file - overview of what's in this folder

QUICK STATS:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF

# Extract stats from the report if it exists
if [ -f "${RUN_FOLDER}/regression_report.json" ]; then
    python3 << 'PYTHON_SCRIPT'
import json
with open("regression_report.json", "r") as f:
    data = json.load(f)
    stats = data.get("statistics", {})
    print(f"Tests Run:        {stats.get('total_tests', 'N/A')}")
    print(f"Tests Passed:     {stats.get('passed_tests', 'N/A')}")
    print(f"Tests Failed:     {stats.get('failed_tests', 'N/A')}")
    print(f"Average Cycles:   {stats.get('average', 'N/A'):.2f}")
    print(f"Median Cycles:    {stats.get('median', 'N/A'):.2f}")
    print(f"Min/Max Cycles:   {stats.get('min', 'N/A')} - {stats.get('max', 'N/A')}")
    print(f"Total Cycles:     {stats.get('total_cycles', 'N/A')}")
PYTHON_SCRIPT
fi >> "${RUN_FOLDER}/RUN_SUMMARY.txt" 2>/dev/null

cat >> "${RUN_FOLDER}/RUN_SUMMARY.txt" << 'EOF'

HOW TO USE THESE FILES:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

View Dashboard Results:
  cat dashboard_output.txt

View Text Summary:
  cat regression_summary.txt

Compare with Previous Run:
  python compare_regression.py auto

Get JSON Data:
  cat regression_report.json | python -m json.tool

Next Steps:
  1. Review the cycle time metrics
  2. Compare against previous runs using compare_regression.py
  3. Make code changes if desired
  4. Run the master script again to generate a new run folder

═══════════════════════════════════════════════════════════════════════════════
EOF

print_success "Summary report created"

# Create a manifest file
print_header "Creating Manifest"

cat > "${RUN_FOLDER}/MANIFEST.json" << EOF
{
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "folder": "$(basename "${RUN_FOLDER}")",
  "full_path": "${RUN_FOLDER}",
  "tests_run": 30,
  "files": {
    "regression_report.json": "Machine-readable test results",
    "regression_summary.txt": "Human-readable test results",
    "regression_history.jsonl": "Historical time-series data",
    "dashboard_output.txt": "Visual dashboard report",
    "analysis_report.txt": "Trend analysis results",
    "regression_test.log": "Raw test output",
    "RUN_SUMMARY.txt": "This run summary",
    "MANIFEST.json": "File manifest"
  }
}
EOF

print_success "Manifest created"

# Generate comparison with previous run if available
print_header "Checking Previous Runs"

PREV_RUNS=$(ls -1d "${RUNS_FOLDER}"/*/ 2>/dev/null | head -2 | tail -1)
if [ -n "$PREV_RUNS" ] && [ "$PREV_RUNS" != "${RUN_FOLDER}" ]; then
    print_info "Previous run found: $(basename "$PREV_RUNS")"
    echo ""
    echo "To compare with previous run, use:"
    echo "  python compare_regression.py auto"
else
    print_info "No previous run found (first baseline run)"
fi

# Create directory listing
print_header "Run Contents"

ls -lh "${RUN_FOLDER}/" | tail -n +2 | awk '{printf "  %-40s %10s\n", $9, $5}'

# Final summary
print_header "Regression Test Complete!"

echo "All results organized in: ${RUN_FOLDER}/"
echo ""
echo "Key files to view:"
echo "  1. cat ${RUN_FOLDER}/RUN_SUMMARY.txt"
echo "  2. cat ${RUN_FOLDER}/dashboard_output.txt"
echo "  3. cat ${RUN_FOLDER}/regression_summary.txt"
echo ""
echo "To view all runs:"
echo "  ls -lh ${RUNS_FOLDER}/"
echo ""
echo "To analyze trends:"
echo "  python analyze_regression.py"
echo ""

print_success "Done!"
echo ""
