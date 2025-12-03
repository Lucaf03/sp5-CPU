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
    MUL, MULH, MULHSU, MULHU, DIV, DIVU, REMM, REMU,
    CSRRW, CSRRS, CSRRC, CSRRWI, CSRRSI, CSRRCI
  );

  constant csr_mvendorid_addr : std_logic_vector(11 downto 0)  := x"F11";
  constant csr_marchid_addr : std_logic_vector(11 downto 0)   := x"F12";
  constant csr_mimpid_addr : std_logic_vector(11 downto 0)    := x"F13";
  constant csr_mhartid_addr : std_logic_vector(11 downto 0)   := x"F14";
  constant csr_mstatus_addr : std_logic_vector(11 downto 0)   := x"300";
  constant csr_misa_addr : std_logic_vector(11 downto 0)      := x"301";

end package sp_pkg;
