#!/bin/bash

# Run the LC-3b simulator with automated commands using a loop.
# This prints a cycle header and sends idump/run 1 commands to the simulator.

SIM=./lc3bsim6.exe
MICROCODE=ucode6
PROGRAM=test.obj
MAX_CYCLES=94

# Build the command stream for the simulator.
cmdfile=$(mktemp)
cat > "$cmdfile" <<'EOF'
idump
EOF
for cycle in $(seq 1 "$MAX_CYCLES"); do
  echo "run 1" >> "$cmdfile"
  echo "idump" >> "$cmdfile"
done
echo "quit" >> "$cmdfile"

# Print headers and run the simulator once with the generated commands.
echo "=== LC-3b Simulation ==="
echo "microcode: $MICROCODE"
echo "program:   $PROGRAM"
echo "cycles:    $MAX_CYCLES"
echo ""
$SIM "$MICROCODE" "$PROGRAM" < "$cmdfile"

rm -f "$cmdfile"