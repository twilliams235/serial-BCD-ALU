# Serial BCD ALU (Verilog)

A serial, packetized **Binary-Coded Decimal (BCD) ALU** that performs 4-digit addition and subtraction. The design ingests data and control serially, converts to parallel internally for computation, then serializes the result back out—bridging serial I/O with parallel arithmetic using SIPO/PISO registers. 

## Highlights

- **Operations**: 4-digit BCD add and subtract (handles carries/borrows and invalid BCD correction). 

- **Serial packets**: Structured control/data packet is shifted into a 41-bit register; results are serialized from a 28-bit output register. 

- **Mode select**: Packet bit 9 (the 9th bit of the shift register) selects add vs. subtract. 

- **Modular design**: Digit adder reused in both add/subtract datapaths; clean ripple across BCD digits. 

## Architecture
### Modules

- **combBCDadd_digit** – BCD digit adder: adds A, B, Cin; corrects sums > 9 by adding 6; produces F and cout. 

- **combBCDadd_4d** – 4-digit BCD adder using combBCDadd_digit in ripple fashion; outputs 5th “digit” carry in F4[0]. 

- **combBCDsub_4d** – 4-digit BCD subtractor implemented as A + (10’s complement of B) via the same digit adder; ripple with Cin=1. 

- **Top (Project2)** – Packet detector + control; feeds operands to add/sub blocks; selects output by shift_reg[8]; writes 28-bit F; serializes result. 

### Dataflow (high level)

- Shift-in serial packet into shift_reg.

- Detect header → assert valid (freeze shifting).

- Select op by shift_reg[8] (0 = add, 1 = sub).

- Compute via combBCDadd_4d / combBCDsub_4d.

- Store parallel result in 28-bit F.

- Shift-out F as the serialized result.

## File Map

- model.v – Top and submodules:

- Project2 (top: packet/shift/control, result serialization)

- combBCDadd_digit (digit adder)

- combBCDadd_4d (4-digit adder)

- combBCDsub_4d (4-digit subtractor)
(Names based on the report; adjust if your file uses different identifiers.)