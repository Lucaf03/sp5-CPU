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
--------------------------------CSR REGISTER ADDRESSES-------------------------------------
  constant csr_mvendorid_addr : std_logic_vector(11 downto 0) := x"F11";
  constant csr_marchid_addr : std_logic_vector(11 downto 0)   := x"F12";
  constant csr_mimpid_addr : std_logic_vector(11 downto 0)    := x"F13";
  constant csr_mhartid_addr : std_logic_vector(11 downto 0)   := x"F14";
  constant csr_mstatus_addr : std_logic_vector(11 downto 0)   := x"300";
  constant csr_misa_addr : std_logic_vector(11 downto 0)      := x"301";
  constant csr_mie_addr : std_logic_vector(11 downto 0)       := x"304";
  constant csr_mip_addr : std_logic_vector(11 downto 0)       := x"344";
  constant csr_mtvec_addr : std_logic_vector(11 downto 0)     := x"305";
  constant csr_mepc_addr : std_logic_vector(11 downto 0)      := x"341";
  constant csr_mcause_addr : std_logic_vector(11 downto 0)    := x"342";
  constant csr_misa_addr : std_logic_vector(11 downto 0)      := x"301";


------------------------------TRAP CODES----------------------------------------------------
  constant INTERRUPT_SSWI_CODE    : std_logic_vector(30 downto 0) := x"00000001";
  constant INTERRUPT_MSWI_CODE    : std_logic_vector(30 downto 0) := x"00000003";
  constant INTERRUPT_STI_CODE     : std_logic_vector(30 downto 0) := x"00000005";
  constant INTERRUPT_MTI_CODE     : std_logic_vector(30 downto 0) := x"00000007";
  constant INTERRUPT_SEI_CODE     : std_logic_vector(30 downto 0) := x"00000009";
  constant INTERRUPT_MEI_CODE     : std_logic_vector(30 downto 0) := x"0000000B";
  constant INTERRUPT_COF_CODE     : std_logic_vector(30 downto 0) := x"0000000D";

  constant EXCEPTION_INSTR_ADDR_MISALIGNED_CODE   : std_logic_vector(30 downto 0) := x"00000000";
  constant EXCEPTION_INSTR_ADDR_ACCESSFAULT_CODE  : std_logic_vector(30 downto 0) := x"00000001";
  constant EXCEPTION_ILLEGAL_INSTR_CODE           : std_logic_vector(30 downto 0) := x"00000002";
  constant EXCEPTION_BREAKPOINT_CODE              : std_logic_vector(30 downto 0) := x"00000003";
  constant EXCEPTION_LOAD_ADDR_MISALIGNED_CODE    : std_logic_vector(30 downto 0) := x"00000004";
  constant EXCEPTION_LOAD_ADDR_ACCESSFAULT_CODE   : std_logic_vector(30 downto 0) := x"00000005";
  constant EXCEPTION_STORE_ADDR_MISALIGNED_CODE   : std_logic_vector(30 downto 0) := x"00000006";
  constant EXCEPTION_STORE_ADDR_ACCESSFAULT_CODE  : std_logic_vector(30 downto 0) := x"00000007";
  constant EXCEPTION_ECALL_U_CODE                 : std_logic_vector(30 downto 0) := x"00000008";
  constant EXCEPTION_ECALL_S_CODE                 : std_logic_vector(30 downto 0) := x"00000009";
  constant EXCEPTION_ECALL_M_CODE                 : std_logic_vector(30 downto 0) := x"0000000B";
  constant EXCEPTION_INSTR_PAGEFAULT_CODE         : std_logic_vector(30 downto 0) := x"0000000C";
  constant EXCEPTION_LOAD_PAGEFAULT_CODE          : std_logic_vector(30 downto 0) := x"0000000D";
  constant EXCEPTION_STORE_PAGEFAULT_CODE         : std_logic_vector(30 downto 0) := x"0000000F";
  constant EXCEPTION_DOUBLE_TRAP_CODE             : std_logic_vector(30 downto 0) := x"00000010";
  constant EXCEPTION_SW_CHECK_CODE                : std_logic_vector(30 downto 0) := x"00000012";
  constant EXCEPTION_HW_ERROR_CODE                : std_logic_vector(30 downto 0) := x"00000013";

end package sp_pkg;
