library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.sp_pkg.all;
--CSR Registers to implement: MSTATUS, MISA, MIE, MTVEC, MEPC, MCAUSE, MVAL, MIP 
entity CSR_unit is 
Port(
	clk_i, rst_i : in std_logic;
	csr_instr_req : in std_logic;
	csr_addr_i : in std_logic_vector(11 downto 0);
	csr_rd_i : in std_logic_vector(4 downto 0);
	csr_rs1_i : in std_logic_vector(4 downto 0);
	csr_imm_i : in std_logic_vector(4 downto 0);
	instr_decoded_i : in INSTR_NAME;

	csr_read_o : out std_logic_vector(31 downto 0)
);
end entity;

architecture RTL of CSR_unit is 
	signal csr_misa_reg : std_logic_vector(31 downto 0); 
	signal csr_mvendorid_reg : std_logic_vector(31 downto 0); 
	signal csr_marchid_reg : std_logic_vector(31 downto 0); 
	signal csr_mimpid_reg : std_logic_vector(31 downto 0); 
	signal csr_mhartid_reg : std_logic_vector(31 downto 0); 
	signal csr_mstatus_reg : std_logic_vector(31 downto 0); 
	signal csr_mstatush_reg : std_logic_vector(31 downto 0); 

	signal csr_read : std_logic_vector(31 downto 0);
	signal csr_op_np : std_logic; --CSR Operation Not Possible signal
begin
	csr_read_o <= csr_read;

	csr_mvendorid_reg <= (others => '0');
	csr_marchid_reg <= (others => '0');
	csr_mimpid_reg <= (others => '0');
	csr_mhartid_reg <= (others => '0');
	csr_misa_reg <= (others => '0');
	process(clk_i, rst_i)
	begin
		if rst_i = '1' then
			csr_op_np <= '0';
		elsif rising_edge(clk_i) then
			if csr_instr_req = '1' then
				csr_op_np <= '0';
				case csr_addr_i is 
					when mvendorid_addr => 
						if instr_decoded_i = CSRRS or instr_decoded_i = CSRRC or 
							instr_decoded_i = CSRRSI or instr_decoded_i = CSRRCI then
							if csr_rs1_i = "00000" then 
								csr_read <= csr_mvendorid_reg;
							else 
								csr_op_np <= '1';
							end if;
						else 
							csr_op_np <= '1';
						end if;
					when marchid_addr => 
						if instr_decoded_i = CSRRS or instr_decoded_i = CSRRC or 
							instr_decoded_i = CSRRSI or instr_decoded_i = CSRRCI then
							if csr_rs1_i = "00000" then 
								csr_read <= csr_marchid_reg;
							else 
								csr_op_np <= '1';
							end if;
						else 
							csr_op_np <= '1';
						end if;
					when csr_mimpid_addr =>
						if instr_decoded_i = CSRRS or instr_decoded_i = CSRRC or 
							instr_decoded_i = CSRRSI or instr_decoded_i = CSRRCI then
							if csr_rs1_i = "00000" then 
								csr_read <= csr_mimpid_reg;
							else 
								csr_op_np <= '1';
							end if;
						else 
							csr_op_np <= '1';
						end if;
					when csr_mhartid_addr => 
						if instr_decoded_i = CSRRS or instr_decoded_i = CSRRC or 
							instr_decoded_i = CSRRSI or instr_decoded_i = CSRRCI then
							if csr_rs1_i = "00000" then 
								csr_read <= csr_mhartid_reg;
							else 
								csr_op_np <= '1';
							end if;
						else 
							csr_op_np <= '1';
						end if;
					when csr_misa_addr => --Could be implemented
						if instr_decoded_i = CSRRS or instr_decoded_i = CSRRC or 
							instr_decoded_i = CSRRSI or instr_decoded_i = CSRRCI then
							if csr_rs1_i = "00000" then 
								csr_read <= csr_misa_reg;
							else 
								csr_op_np <= '1';
							end if;
						else 
							csr_op_np <= '1';
						end if;
					when others => 
						csr_op_np <= '1';
						csr_read <= (others => '0');
				end case;
			end if;
		end if;
	end process;
end RTL;
