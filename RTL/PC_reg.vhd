library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.sp_pkg.all;

entity PC_reg is
Port (
    instr_addr_o : out std_logic_vector(31 downto 0);
    pc_update_i, br_update_i : in std_logic;
    clk_i, rst_i : in std_logic;
    fetch_req_i : in std_logic;
    instr_mem_en_o : out std_logic;
    instr_addr_i : in std_logic_vector(31 downto 0)
 );
end PC_reg;

architecture RTL of PC_reg is
    signal pc_acc : std_logic_vector(31 downto 0) := x"FFFFFFFC";
    signal instr_mem_en : std_logic;
begin 
    instr_mem_en_o <= instr_mem_en and fetch_req_i;
    process(clk_i, rst_i) 
    begin
        if rst_i = '1' then
            pc_acc <= (others => '0');
        elsif rising_edge(clk_i) then
            if br_update_i = '1' then
                pc_acc <= instr_addr_i;
            else 
                if pc_update_i = '1' then
                    pc_acc <= std_logic_vector(signed(pc_acc) + 4);
                else 
                    pc_acc <= pc_acc;
                end if;
            end if;
        end if;
    end process;

    process(pc_acc) 
    begin 
        if pc_acc >= x"00000000" and pc_acc < x"00002000" then
            instr_addr_o <= pc_acc;
            instr_mem_en <= '1';
        else 
            instr_addr_o <= (others => '0');
            instr_mem_en <= '0';
        end if;
    end process;
end RTL;
