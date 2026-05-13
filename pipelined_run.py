import subprocess
import re
from collections import deque

# --- Configuration ---
SIM = "./lc3bsim6.exe"
UCODE = "ucode6"
PROGRAM = "test.obj"
MAX_CYCLES = 94


def sext(x, bits):
    if x & (1 << (bits - 1)):
        x -= (1 << bits)
    return x


def disassemble(hex_str):
    v = int(hex_str, 16)
    op = (v >> 12) & 0xF

    if v == 0xFEED:
        return "I$ miss"
    if v == 0x0000:
        return "NOP"

    if op == 0x0:
        nzp = (
            ("n" if v & 0x0800 else "") +
            ("z" if v & 0x0400 else "") +
            ("p" if v & 0x0200 else "")
        )
        off9 = sext(v & 0x1FF, 9)
        if nzp == "":
            return "NOP"
        return f"BR{nzp} {off9:+d}"

    if op == 0x1:
        dr = (v >> 9) & 7
        sr1 = (v >> 6) & 7
        if v & 0x20:
            imm5 = sext(v & 0x1F, 5)
            return f"ADD R{dr}, R{sr1}, #{imm5}"
        sr2 = v & 7
        return f"ADD R{dr}, R{sr1}, R{sr2}"

    if op == 0x2:
        dr = (v >> 9) & 7
        baser = (v >> 6) & 7
        off6 = sext(v & 0x3F, 6)
        return f"LDB R{dr}, R{baser}, #{off6}"

    if op == 0x3:
        sr = (v >> 9) & 7
        baser = (v >> 6) & 7
        off6 = sext(v & 0x3F, 6)
        return f"STB R{sr}, R{baser}, #{off6}"

    if op == 0x4:
        if (v >> 11) & 1:
            off11 = sext(v & 0x7FF, 11)
            return f"JSR {off11:+d}"
        baser = (v >> 6) & 7
        return f"JSRR R{baser}"

    if op == 0x5:
        dr = (v >> 9) & 7
        sr1 = (v >> 6) & 7
        if v & 0x20:
            imm5 = sext(v & 0x1F, 5)
            return f"AND R{dr}, R{sr1}, #{imm5}"
        sr2 = v & 7
        return f"AND R{dr}, R{sr1}, R{sr2}"

    if op == 0x6:
        dr = (v >> 9) & 7
        baser = (v >> 6) & 7
        off6 = sext(v & 0x3F, 6)
        return f"LDW R{dr}, R{baser}, #{off6}"

    if op == 0x7:
        sr = (v >> 9) & 7
        baser = (v >> 6) & 7
        off6 = sext(v & 0x3F, 6)
        return f"STW R{sr}, R{baser}, #{off6}"

    if op == 0x8:
        return "RTI"

    if op == 0x9:
        dr = (v >> 9) & 7
        sr1 = (v >> 6) & 7
        if ((v >> 5) & 1) == 0 and (v & 0x1F) == 0x1F:
            return f"NOT R{dr}, R{sr1}"
        if (v >> 5) & 1:
            imm5 = sext(v & 0x1F, 5)
            return f"XOR R{dr}, R{sr1}, #{imm5}"
        sr2 = v & 7
        return f"XOR R{dr}, R{sr1}, R{sr2}"

    if op == 0xC:
        baser = (v >> 6) & 7
        if baser == 7:
            return "RET"
        return f"JMP R{baser}"

    if op == 0xE:
        dr = (v >> 9) & 7
        off9 = sext(v & 0x1FF, 9)
        return f"LEA R{dr}, {off9:+d}"

    if op == 0xF:
        vec = v & 0xFF
        if vec == 0x25:
            return "HALT"
        return f"TRAP x{vec:02X}"

    return f"HEX {hex_str.upper()}"


def get_obj_data(filename):
    obj_map = {}
    with open(filename, "r") as f:
        lines = [line.strip().upper() for line in f if line.strip()]

    base = int(lines[0], 16)
    pc = base

    for h in lines[1:]:
        h_clean = h.replace("0X", "").zfill(4)
        addr = f"0X{pc:04X}"
        obj_map[addr] = {
            "hex": h_clean,
            "asm": disassemble(h_clean)
        }
        pc += 2

    return obj_map


def run_simulation():
    cmds = "idump\n" + \
        "".join("run 1\nidump\n" for _ in range(MAX_CYCLES)) + "quit\n"

    proc = subprocess.Popen(
        [SIM, UCODE, PROGRAM],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        shell=False
    )
    stdout, _ = proc.communicate(input=cmds)
    return stdout


def build_timeline(output, obj_map):
    parts = re.split(r'Current architectural state\s*:\s*', output)
    snapshots = []

    for part in parts:
        if "Cycle Count" not in part:
            continue

        def grab_hex(name):
            m = re.search(rf'{name}\s*:\s*0x([0-9a-fA-F]+)', part)
            return int(m.group(1), 16) if m else 0

        def grab_dec(name):
            m = re.search(rf'{name}\s*:\s*(\d+)', part)
            return int(m.group(1)) if m else 0

        snapshots.append({
            "cycle": grab_dec("Cycle Count"),
            "pc": grab_hex("PC"),

            "icache_r": grab_dec("ICACHE_R"),
            "dep_stall": grab_dec("DEP_STALL"),
            "v_de_br_stall": grab_dec("V_DE_BR_STALL"),
            "v_agex_br_stall": grab_dec("V_AGEX_BR_STALL"),
            "mem_stall": grab_dec("MEM_STALL"),
            "v_mem_br_stall": grab_dec("V_MEM_BR_STALL"),

            "de_npc": grab_hex("DE_NPC"),
            "de_ir": grab_hex("DE_IR"),
            "de_v": grab_dec("DE_V"),

            "agex_npc": grab_hex("AGEX_NPC"),
            "agex_ir": grab_hex("AGEX_IR"),
            "agex_v": grab_dec("AGEX_V"),

            "mem_npc": grab_hex("MEM_NPC"),
            "mem_ir": grab_hex("MEM_IR"),
            "mem_v": grab_dec("MEM_V"),

            "sr_npc": grab_hex("SR_NPC"),
            "sr_ir": grab_hex("SR_IR"),
            "sr_v": grab_dec("SR_V"),
        })

    if not snapshots:
        print("No snapshots parsed.")
        return

    snapshots.sort(key=lambda s: s["cycle"])

    class Inst:
        def __init__(self, iid, addr, asm):
            self.id = iid
            self.addr = addr
            self.asm = asm
            self.cells = {}

    instances = []
    inst_by_id = {}
    next_id = 0

    def new_inst(addr):
        nonlocal next_id
        asm = obj_map.get(addr, {}).get("asm", f"x{int(addr, 16):04X}")
        ins = Inst(next_id, addr, asm)
        instances.append(ins)
        inst_by_id[next_id] = ins
        next_id += 1
        return ins.id

    fetch_queue = deque()
    prev_stage_ids = {"D": None, "A": None, "M": None, "S": None}

    def npc_to_addr(npc):
        return f"0X{((npc - 2) & 0xFFFF):04X}"

    def stage_addr(prev_snap, stage):
        if stage == "D" and prev_snap["de_v"]:
            return npc_to_addr(prev_snap["de_npc"])
        if stage == "A" and prev_snap["agex_v"]:
            return npc_to_addr(prev_snap["agex_npc"])
        if stage == "M" and prev_snap["mem_v"]:
            return npc_to_addr(prev_snap["mem_npc"])
        if stage == "S" and prev_snap["sr_v"]:
            return npc_to_addr(prev_snap["sr_npc"])
        return None

    for i in range(1, len(snapshots)):
        prev = snapshots[i - 1]
        curr = snapshots[i]
        t = curr["cycle"]

        # F stage
        freeze_frontend = (
            curr["mem_stall"] or
            curr["dep_stall"] or
            curr["v_de_br_stall"] or
            curr["v_agex_br_stall"]
        )

        if not freeze_frontend:
            f_addr = f"0X{prev['pc']:04X}"
            if f_addr in obj_map:
                if fetch_queue:
                    tail = inst_by_id[fetch_queue[-1]]
                    if tail.addr == f_addr and tail.cells.get(t - 1) == "F":
                        iid = tail.id
                    else:
                        iid = new_inst(f_addr)
                        fetch_queue.append(iid)
                else:
                    iid = new_inst(f_addr)
                    fetch_queue.append(iid)

                inst_by_id[iid].cells[t] = "F"

        current_stage_ids = {"D": None, "A": None, "M": None, "S": None}

        # D stage
        d_addr = stage_addr(prev, "D")
        if d_addr and d_addr in obj_map:
            iid = None

            if prev_stage_ids["D"] is not None and inst_by_id[prev_stage_ids["D"]].addr == d_addr:
                iid = prev_stage_ids["D"]
            else:
                for cand in list(fetch_queue):
                    if inst_by_id[cand].addr == d_addr:
                        iid = cand
                        fetch_queue.remove(cand)
                        break

            if iid is None:
                iid = new_inst(d_addr)

            inst_by_id[iid].cells[t] = "D"
            current_stage_ids["D"] = iid

        # A stage
        a_addr = stage_addr(prev, "A")
        if a_addr and a_addr in obj_map:
            iid = None

            for key in ("A", "D"):
                pid = prev_stage_ids[key]
                if pid is not None and inst_by_id[pid].addr == a_addr:
                    iid = pid
                    break

            if iid is None and current_stage_ids["D"] is not None and inst_by_id[current_stage_ids["D"]].addr == a_addr:
                iid = current_stage_ids["D"]

            if iid is None:
                iid = new_inst(a_addr)

            inst_by_id[iid].cells[t] = "A"
            current_stage_ids["A"] = iid

        # M stage
        m_addr = stage_addr(prev, "M")
        if m_addr and m_addr in obj_map:
            iid = None

            for key in ("M", "A", "D"):
                pid = prev_stage_ids[key]
                if pid is not None and inst_by_id[pid].addr == m_addr:
                    iid = pid
                    break

            if iid is None and current_stage_ids["A"] is not None and inst_by_id[current_stage_ids["A"]].addr == m_addr:
                iid = current_stage_ids["A"]

            if iid is None:
                iid = new_inst(m_addr)

            inst_by_id[iid].cells[t] = "M"
            current_stage_ids["M"] = iid

        # S stage
        s_addr = stage_addr(prev, "S")
        if s_addr and s_addr in obj_map:
            iid = None

            for key in ("S", "M", "A", "D"):
                pid = prev_stage_ids[key]
                if pid is not None and inst_by_id[pid].addr == s_addr:
                    iid = pid
                    break

            if iid is None and current_stage_ids["M"] is not None and inst_by_id[current_stage_ids["M"]].addr == s_addr:
                iid = current_stage_ids["M"]

            if iid is None:
                iid = new_inst(s_addr)

            inst_by_id[iid].cells[t] = "S"
            current_stage_ids["S"] = iid

        prev_stage_ids = current_stage_ids

    instances = [ins for ins in instances if any(
        v in {"D", "A", "M", "S"} for v in ins.cells.values())]
    instances.sort(key=lambda ins: min(
        ins.cells.keys()) if ins.cells else 10**9)

    print("F: Fetch stage")
    print("D: Decode stage")
    print("A: AGEX stage")
    print("M: Memory stage")
    print("S: SR stage")
    print()

    if not instances:
        print("No instructions reached the pipeline.")
        return

    used_cycles = sorted({c for ins in instances for c in ins.cells})
    max_used = max(used_cycles)

    label_width = max(len("Instruction"), max(len(ins.asm)
                      for ins in instances))
    cellw = max(2, len(str(max_used))) + 1

    print(" " * (label_width + 2) + "Cycle")
    print(f'{"Instruction".ljust(label_width)}  ' +
          "".join(f"{c:>{cellw}}" for c in range(1, max_used + 1)))
    print("-" * (label_width + 2 + cellw * max_used))

    for ins in instances:
        row = [ins.asm.ljust(label_width), "  "]
        for c in range(1, max_used + 1):
            row.append(f'{ins.cells.get(c, ""):>{cellw}}')
        print("".join(row))


if __name__ == "__main__":
    print("Capturing simulation history...")
    raw_data = run_simulation()
    obj_info = get_obj_data(PROGRAM)
    build_timeline(raw_data, obj_info)
