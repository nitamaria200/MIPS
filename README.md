# 16-bit MIPS

A 16-bit MIPS-based processor with a 5-stage pipeline, written in VHDL and tested on an FPGA board.

## How it works

The pipeline uses the usual five stages:

1. **Fetch.** The PC reads an instruction from a 256-word ROM and computes PC + 1.
2. **Decode.** This stage reads the register file, generates the control signals from the opcode, and extends the immediate.
3. **Execute.** The ALU does the operation. The branch target address is also calculated here.
4. **Memory.** Loads and stores happen here, and this is where a `beq` decides whether to branch.
5. **Write back.** The result goes back into the register file.

Between each pair of stages there's a pipeline register. It carries the data forward, along with the control signals that later stages still need.

The register file has 8 registers of 16 bits. It writes on the falling edge of the clock, so a value written back in WB can be read in ID during the same cycle. That saves one NOP between dependent instructions.

## Instruction set

Instructions are 16 bits long and come in three formats:

```
R:  opcode(3) | rs(3) | rt(3) | rd(3) | sa(1) | func(3)
I:  opcode(3) | rs(3) | rt(3) | imm(7)
J:  opcode(3) | address(13)
```

| Instruction | Opcode | Func | What it does |
|---|---|---|---|
| add | 000 | 000 | rd = rs + rt |
| sub | 000 | 001 | rd = rs - rt |
| sll | 000 | 010 | rd = rs << 1 |
| srl | 000 | 011 | rd = rs >> 1 |
| and | 000 | 100 | rd = rs & rt |
| or  | 000 | 101 | rd = rs \| rt |
| xor | 000 | 110 | rd = rs ^ rt |
| slt | 000 | 111 | rd = 1 if rs < rt, else 0 |
| addi | 001 | | rt = rs + imm |
| lw | 010 | | rt = MEM[rs + imm] |
| sw | 011 | | MEM[rs + imm] = rt |
| beq | 100 | | if rs == rt, branch to PC + 1 + imm |
| ori | 101 | | rt = rs \| imm (zero-extended) |
| slti | 110 | | rt = 1 if rs < imm, else 0 |
| j | 111 | | jump to address |

## Hazards

The processor has no forwarding unit and no hazard detection. I handled hazards in the program itself by putting NOPs in the right places:

- **Dependent instructions.** Two NOPs are needed when an instruction uses a register the previous one writes.
- **`beq`.** Three NOPs are needed after it, because the branch is only decided in the MEM stage.
- **`j`.** One NOP is needed after it, because the jump is decided in ID.

The test program in the ROM goes through every instruction type. It runs a store followed by a load, takes a branch that skips two instructions, and ends with a jump that loops back.

## Running it on the board

- **`btn[0]`** advances one clock cycle.
- **`btn[1]`** resets the PC and clears the pipeline.
- **`sw[11:9]`** picks the value shown on the left half of the display.
- **`sw[6:4]`** picks the value shown on the right half.
- **LEDs** show the control signals for the instruction in decode.

Values for the display switches:

| Switches | Shown on display |
|---|---|
| 000 | instruction |
| 001 | PC + 1 |
| 010 | register rs |
| 011 | register rt |
| 100 | extended immediate |
| 101 | ALU result |
| 110 | memory data |
| 111 | write-back data |

To build it in Vivado:

1. Add all the `.vhd` files.
2. Set `ex1` (in `proba1.vhd`) as the top module.
3. Add your board's constraints file.
4. Generate the bitstream.

## Files

- `proba1.vhd` is the top level. It connects all the stages and holds the pipeline registers and the display/LED logic.
- `inst_fetch.vhd` has the PC, the instruction ROM and the test program.
- `instr_decode.vhd` contains the register file, the destination register mux and the immediate extension.
- `control_unit.vhd` is the main control unit.
- `exec_unit.vhd` contains the ALU, the ALU control and the branch address adder.
- `mem_unit.vhd` and `ram.vhd` make up the data memory.
- `reg_file.vhd` is the register file.
- `monopulse_gen.vhd` debounces the buttons, so each press counts as exactly one clock cycle.
- `seven_segment_dispaly.vhd` drives the 7-segment display.
- `register_file.vhd` is an older 32-bit version of the register file. It isn't used anymore.
