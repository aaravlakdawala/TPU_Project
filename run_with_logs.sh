#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT_DIR"

# Find the next unused TestN folder name.
next_test=1
mkdir -p "logs"
while [ -d "logs/Test${next_test}" ]; do
  next_test=$((next_test + 1))
done
TEST_DIR="logs/Test${next_test}"
mkdir -p "$TEST_DIR"

ASM_SRC="test.asm"
OBJ_OUT="$TEST_DIR/test${next_test}.obj"
ASM_COPY="$TEST_DIR/test${next_test}.asm"

if [ ! -f "$ASM_SRC" ]; then
  echo "Error: $ASM_SRC not found in $ROOT_DIR"
  exit 1
fi

cp "$ASM_SRC" "$ASM_COPY"

echo "=== Compiling lc3bsim6.cpp ==="
if [ ! -f "./lc3bsim6.cpp" ]; then
  echo "Error: lc3bsim6.cpp not found in $ROOT_DIR"
  exit 1
fi

g++ -o ./lc3bsim6.exe ./lc3bsim6.cpp > "$TEST_DIR/compile_sim_result.txt" 2>&1 || {
  echo "Error: failed to compile lc3bsim6.cpp (see $TEST_DIR/compile_sim_result.txt)"
  exit 1
}

echo "=== Running build_obj.sh for $TEST_DIR ==="
bash ./build_obj.sh "$ASM_SRC" "$OBJ_OUT" > "$TEST_DIR/build_obj_result.txt" 2>&1

if [ ! -f "$OBJ_OUT" ]; then
  echo "Error: build_obj.sh did not create $OBJ_OUT"
  exit 1
fi

# Probe the simulator to determine the cycle count.
echo "=== Probing simulator for Cycle Count ==="
cat > "$TEST_DIR/probe_sim_cmds.txt" <<'EOF'
go
rdump
quit
EOF

./lc3bsim6.exe ucode6 "$OBJ_OUT" < "$TEST_DIR/probe_sim_cmds.txt" > "$TEST_DIR/probe_sim_output.txt" 2>&1

CYCLE_COUNT=$(PROBE_FILE="$TEST_DIR/probe_sim_output.txt" python3 - <<'PY'
import os, re, pathlib
text = pathlib.Path(os.environ['PROBE_FILE']).read_text()
m = re.search(r'Cycle Count\s*:\s*(\d+)', text)
print(m.group(1) if m else '')
PY
)

if [ -z "$CYCLE_COUNT" ]; then
  echo "Error: failed to detect Cycle Count from simulator output"
  exit 1
fi

echo "Detected Cycle Count: $CYCLE_COUNT"

echo "=== Updating MAX_CYCLES in pipelined_run.py and run_sim.sh ==="
CYCLE_COUNT="$CYCLE_COUNT" python3 - <<'PY'
import os, re, pathlib
count = os.environ['CYCLE_COUNT']
for path, pattern in {
    'pipelined_run.py': r'^(MAX_CYCLES\s*=\s*)\d+',
    'run_sim.sh': r'^(MAX_CYCLES\s*=\s*)\d+'
}.items():
    p = pathlib.Path(path)
    text = p.read_text()
    def repl(match):
        return match.group(1) + count
    new = re.sub(pattern, repl, text, flags=re.MULTILINE)
    p.write_text(new)
PY

echo "=== Running python pipelined_run.py for $TEST_DIR ==="
# Copy the generated test.obj into project root so pipelined_run.py can use it.
cp "$OBJ_OUT" "test.obj"
python3 ./pipelined_run.py > "$TEST_DIR/pipelined_result${next_test}.txt" 2>&1

echo "=== Running run_sim.sh and saving output to run_sim_result.txt ==="
cp "$OBJ_OUT" "test.obj"
bash ./run_sim.sh > "$TEST_DIR/run_sim_result${next_test}.txt" 2>&1

echo "=== Organizing metadata files ==="
mkdir -p "$TEST_DIR/metadata"
mv "$TEST_DIR/build_obj_result.txt" "$TEST_DIR/compile_sim_result.txt" "$TEST_DIR/probe_sim_cmds.txt" "$TEST_DIR/probe_sim_output.txt" "$TEST_DIR/metadata/"

echo "=== Completed Test folder: $TEST_DIR ==="
echo "- ASM saved: $ASM_COPY"
echo "- OBJ saved: $OBJ_OUT"
echo "- pipelined result: $TEST_DIR/pipelined_result${next_test}.txt"
echo "- run sim result: $TEST_DIR/run_sim_result${next_test}.txt"
echo "- metadata: $TEST_DIR/metadata/"
