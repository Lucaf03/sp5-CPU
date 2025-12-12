library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.sp_pkg.all;
--CSR Registers to implement: MSTATUS, MISA, MIE, MTVEC, MEPC, MCAUSE, MVAL, MIP 
entity CSR_unit is 
Port(
	clk_i, rst_i : in std_logic;
	CSR_start : in std_logic;
	csr_addr_i : in std_logic_vector(11 downto 0);
	csr_rd_i : in std_logic_vector(4 downto 0);
	csr_op1_addr_i : in std_logic_vector(31 downto 0);
	--csr_rs1_i : in std_logic_vector(31 downto 0);
	csr_op_i : in std_logic_vector(31 downto 0);
	instr_decoded_i : in INSTR_NAME;
	csr_rd_o : out std_logic_vector(4 downto 0);
	WB_start_o : out std_logic;
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
	signal csr_mie_reg : std_logic_vector(31 downto 0);
	signal csr_mip_reg : std_logic_vector(31 downto 0);
	signal csr_mtvec_reg : std_logic_vector(31 downto 0);
	signal csr_mepc_reg : std_logic_vector(31 downto 0);
	signal csr_mcause_reg : std_logic_vector(31 downto 0);

	signal csr_read : std_logic_vector(31 downto 0);
	signal csr_op_np : std_logic; --CSR Operation Not Possible signal
begin
	csr_read_o <= csr_read;



	process(clk_i, rst_i)
	begin
		if rst_i = '1' then
			csr_mvendorid_reg <= (others => '0');
			csr_marchid_reg <= (others => '0');
			csr_mimpid_reg <= (others => '0');
			csr_mhartid_reg <= (others => '0');
			csr_misa_reg <= (others => '0');
			csr_mstatus_reg <= (others => '0');
			csr_op_np <= '0';
			csr_rd_o <= (others => '0');
			csr_read <= (others => '0');
			WB_start_o <= '0';
		elsif rising_edge(clk_i) then
			if CSR_start = '1' then
				WB_start_o <= '1';
				csr_rd_o <= csr_rd_i;
				csr_op_np <= '0';
				case csr_addr_i is 
					when csr_mvendorid_addr => 
						if instr_decoded_i = CSRRS or instr_decoded_i = CSRRC or 
							instr_decoded_i = CSRRSI or instr_decoded_i = CSRRCI then
							if csr_op1_addr_i = x"00000000" then 
								csr_read <= csr_mvendorid_reg;
							else 
								csr_op_np <= '1';
							end if;
						else 
							csr_op_np <= '1';
						end if;

					when csr_marchid_addr => 
						if instr_decoded_i = CSRRS or instr_decoded_i = CSRRC or 
							instr_decoded_i = CSRRSI or instr_decoded_i = CSRRCI then
							if csr_op1_addr_i = x"00000000" then 
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
							if csr_op1_addr_i = x"00000000" then 
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
							if csr_op1_addr_i = x"00000000" then 
								csr_read <= csr_mhartid_reg;
							else 
								csr_op_np <= '1';
							end if;
						else 
							csr_op_np <= '1';
						end if;

					when csr_mstatus_addr => 
						if instr_decoded_i = CSRRW or instr_decoded_i = CSRRWI then
							if csr_rd_i = "00000" then
								csr_mstatus_reg <= csr_op_i;
							else 
								csr_mstatus_reg <= csr_op_i;
								csr_read <= csr_mstatus_reg;
							end if;
						elsif instr_decoded_i = CSRRS or instr_decoded_i = CSRRSI then
							if csr_op1_addr_i = x"00000000" then 
								csr_read <= csr_mstatus_reg;
							else 
								csr_read <= csr_mstatus_reg;
								csr_mstatus_reg <= csr_mstatus_reg or csr_op_i;
							end if;
						elsif instr_decoded_i = CSRRC or instr_decoded_i = CSRRCI then
							if csr_op1_addr_i = x"00000000" then
								csr_read <= csr_mstatus_reg;
							else 
								csr_read <= csr_mstatus_reg;
								csr_mstatus_reg <= csr_mstatus_reg and (not csr_op_i);
							end if;	
						end if;	

					when csr_misa_addr => --Could be implemented
						if instr_decoded_i = CSRRS or instr_decoded_i = CSRRC or 
							instr_decoded_i = CSRRSI or instr_decoded_i = CSRRCI then
							if csr_op1_addr_i = x"00000000" then 
								csr_read <= csr_misa_reg;
							else 
								csr_op_np <= '1';
							end if;
						else 
							csr_op_np <= '1';
						end if;
					when csr_mip_addr => 
						if instr_decoded_i = CSRRW or instr_decoded_i = CSRRWI then
							if csr_rd_i = "00000" then
								csr_mip_reg <= csr_op_i;
							else 
								csr_mip_reg <= csr_op_i;
								csr_read <= csr_mip_reg;
							end if;
						elsif instr_decoded_i = CSRRS or instr_decoded_i = CSRRSI then
							if csr_op1_addr_i = x"00000000" then 
								csr_read <= csr_mip_reg;
							else 
								csr_read <= csr_mip_reg;
								csr_mip_reg <= csr_mip_reg or csr_op_i;
							end if;
						elsif instr_decoded_i = CSRRC or instr_decoded_i = CSRRCI then
							if csr_op1_addr_i = x"00000000" then
								csr_read <= csr_mip_reg;
							else 
								csr_read <= csr_mip_reg;
								csr_mip_reg <= csr_mip_reg and (not csr_op_i);
							end if;	
						end if;	
					when csr_mie_addr => 
						if instr_decoded_i = CSRRW or instr_decoded_i = CSRRWI then
							if csr_rd_i = "00000" then
								csr_mie_reg <= csr_op_i;
							else 
								csr_mie_reg <= csr_op_i;
								csr_read <= csr_mie_reg;
							end if;
						elsif instr_decoded_i = CSRRS or instr_decoded_i = CSRRSI then
							if csr_op1_addr_i = x"00000000" then 
								csr_read <= csr_mie_reg;
							else 
								csr_read <= csr_mie_reg;
								csr_mie_reg <= csr_mie_reg or csr_op_i;
							end if;
						elsif instr_decoded_i = CSRRC or instr_decoded_i = CSRRCI then
							if csr_op1_addr_i = x"00000000" then
								csr_read <= csr_mie_reg;
							else 
								csr_read <= csr_mie_reg;
								csr_mie_reg <= csr_mie_reg and (not csr_op_i);
							end if;	
						end if;	
					when csr_mtvec_addr => 
						if instr_decoded_i = CSRRW or instr_decoded_i = CSRRWI then
							if csr_rd_i = "00000" then
								csr_mtvec_reg <= csr_op_i;
							else 
								csr_mtvec_reg <= csr_op_i;
								csr_read <= csr_mtvec_reg;
							end if;
						elsif instr_decoded_i = CSRRS or instr_decoded_i = CSRRSI then
							if csr_op1_addr_i = x"00000000" then 
								csr_read <= csr_mtvec_reg;
							else 
								csr_read <= csr_mtvec_reg;
								csr_mtvec_reg <= csr_mtvec_reg or csr_op_i;
							end if;
						elsif instr_decoded_i = CSRRC or instr_decoded_i = CSRRCI then
							if csr_op1_addr_i = x"00000000" then
								csr_read <= csr_mtvec_reg;
							else 
								csr_read <= csr_mtvec_reg;
								csr_mtvec_reg <= csr_mtvec_reg and (not csr_op_i);
							end if;	
						end if;	
					when csr_mepc_addr => 
						if instr_decoded_i = CSRRW or instr_decoded_i = CSRRWI then
							if csr_rd_i = "00000" then
								csr_mepc_reg <= csr_op_i;
							else 
								csr_mepc_reg <= csr_op_i;
								csr_read <= csr_mepc_reg;
							end if;
						elsif instr_decoded_i = CSRRS or instr_decoded_i = CSRRSI then
							if csr_op1_addr_i = x"00000000" then 
								csr_read <= csr_mepc_reg;
							else 
								csr_read <= csr_mepc_reg;
								csr_mepc_reg <= csr_mepc_reg or csr_op_i;
							end if;
						elsif instr_decoded_i = CSRRC or instr_decoded_i = CSRRCI then
							if csr_op1_addr_i = x"00000000" then
								csr_read <= csr_mepc_reg;
							else 
								csr_read <= csr_mepc_reg;
								csr_mepc_reg <= csr_mepc_reg and (not csr_op_i);
							end if;	
						end if;	
					when csr_mcause_addr => 
						if instr_decoded_i = CSRRW or instr_decoded_i = CSRRWI then
							if csr_rd_i = "00000" then
								csr_mcause_reg <= csr_op_i;
							else 
								csr_mcause_reg <= csr_op_i;
								csr_read <= csr_mcause_reg;
							end if;
						elsif instr_decoded_i = CSRRS or instr_decoded_i = CSRRSI then
							if csr_op1_addr_i = x"00000000" then 
								csr_read <= csr_mcause_reg;
							else 
								csr_read <= csr_mcause_reg;
								csr_mcause_reg <= csr_mcause_reg or csr_op_i;
							end if;
						elsif instr_decoded_i = CSRRC or instr_decoded_i = CSRRCI then
							if csr_op1_addr_i = x"00000000" then
								csr_read <= csr_mcause_reg;
							else 
								csr_read <= csr_mcause_reg;
								csr_mcause_reg <= csr_mcause_reg and (not csr_op_i);
							end if;	
						end if;	
					when others => 
						csr_op_np <= '1';
						csr_read <= (others => '0');
				end case;
			else 
				WB_start_o <= '0';
				csr_rd_o <= (others => '0');
			end if;
		end if;
	end process;
end RTL;
