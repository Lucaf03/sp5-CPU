library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.sp_pkg.all;

--TODO-FUTURE: BTB

entity Branch_Unit is 
Port
(
	clk_i, rst_i : in std_logic;
	instr_i : in std_logic_vector(31 downto 0);
	PC : in std_logic_vector(31 downto 0);
	br_update_i : in std_logic;
	br_addr_i : in std_logic_vector(31 downto 0);
	br_update_o : out std_logic;
	is_jal_o : out std_logic;
	IF_start_o : out std_logic;
	jump_addr_o: out std_logic_vector(31 downto 0);
	raise_exception_br : out std_logic;
	exception_cause : out std_logic_vector(30 downto 0)
);
end entity;

architecture RTL of Branch_Unit is
	signal instr_fetched: std_logic_vector(31 downto 0);
	signal jump_addr : std_logic_vector(31 downto 0);
	signal br_addr : std_logic_vector(31 downto 0);
    signal is_jal : std_logic;
    signal is_branch : std_logic;
    signal j_update : std_logic;
    signal br_update : std_logic;
    signal count : std_logic_vector(1 downto 0);

begin
	instr_fetched <= instr_i;
    br_update <= br_update_i;
    br_addr <= br_addr_i;

    br_update_o <= j_update when is_jal = '1' else br_update;
    jump_addr_o <= jump_addr when is_jal = '1' else br_addr;
    is_jal_o <= is_jal;

	is_jal <= '1' when instr_fetched(6 downto 0) = "1101111" else '0';
	is_branch <= '1' when instr_fetched(6 downto 0) = "1100011" else '0';

	JAL_PROC : process(all)
	    variable jal_rd : std_logic_vector(4 downto 0);
        variable jal_imm : std_logic_vector(20 downto 0);
        variable jal_addr : std_logic_vector(31 downto 0);
	begin 
		if is_jal = '1' then --JAL
            j_update <= '1';
            jal_imm := (instr_fetched(31) & instr_fetched(19 downto 12) & instr_fetched(20) & instr_fetched(30 downto 21) & '0');
            jal_addr :=  (31 downto 21 => jal_imm(20)) & jal_imm;
            jump_addr <= std_logic_vector(signed(PC) + signed(jal_addr));
        else 
        	j_update <= '0';
        	jump_addr <= (others => '0');
        end if;
	end process;

	--Always Not Taken Policy: Every branch is assumed not taken, so the CPU stalls 3 clock cycles
	COUNT_PROC : process(rst_i, clk_i)
	begin 
		if rst_i = '1' then
			count <= (others => '0');
		elsif rising_edge(clk_i) then
			case count is 
				when "00" =>
					if is_branch = '1' then
						count <= "01";
						IF_start_o <= '0';
					else 	
						count <= "00";
						IF_start_o <= '1';
					end if;
				when "01" => 
					count <= "10";
					IF_start_o <= '0';
				when "10" => 
					count <= "11";
					IF_start_o <= '0';
				when "11" => 
					count <= "00";
					IF_start_o <= '1';
				when others => 
					count <= "00";
					IF_start_o <= '0';
			end case;
		end if;
	end process;

	process(jump_addr, br_addr_i) begin
		if jump_addr(1 downto 0) /= "00" or br_addr_i(1 downto 0) /= "00" then
			raise_exception_br <= '1';
		else 
			raise_exception_br <= '0';
		end if;
	end process;
end RTL;