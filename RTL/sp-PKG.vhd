library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package sp_pkg is

  type INSTR_NAME is (
    ADD, SUB, SLLR, SLT, SLTU, XORR, SRLR, SRAR, ORR, ANDR,
    ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI,
    LB, LH, LW, LBU, LHU,
    SB, SH, SW,
    BEQ, BNE, BLT, BGE, BLTU, BGEU,
    LUI, AUIPC,
    JAL, JALR,
    NOP,
    MUL, MULH, MULHSU, MULHU, DIV, DIVU, REMM, REMU
  );

end package sp_pkg;
