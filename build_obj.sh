#!/usr/bin/env bash
set -euo pipefail

ASM_FILE="${1:-test.asm}"
OBJ_FILE="${2:-test.obj}"

if ! command -v dos2unix >/dev/null 2>&1; then
  echo "Error: dos2unix is not installed or not in PATH."
  exit 1
fi

if [ ! -f "$ASM_FILE" ]; then
  echo "Error: ASM file not found: $ASM_FILE"
  exit 1
fi

if [ ! -f "./assembler.linux" ]; then
  echo "Error: assembler.linux not found in $(pwd)"
  exit 1
fi

printf 'Running dos2unix on %s\n' "$ASM_FILE"
dos2unix "$ASM_FILE"

printf 'Running dos2unix on ucode6\n'
dos2unix ucode6

if [ ! -x "./assembler.linux" ]; then
  chmod +x ./assembler.linux
fi

printf 'Running assembler.linux %s %s\n' "$ASM_FILE" "$OBJ_FILE"
./assembler.linux "$ASM_FILE" "$OBJ_FILE"

printf 'Done. Output written to %s\n' "$OBJ_FILE"
