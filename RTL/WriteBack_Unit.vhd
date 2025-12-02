library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.sp_pkg.all;


entity WriteBack_Unit is
Port (
    clk_i, rst_i : in std_logic;
    data_i : in std_logic_vector(31 downto 0);
    data_o : out std_logic_vector(31 downto 0);
    wr_rf_o : out std_logic; 
    PC_IE : in std_logic_vector(31 downto 0);
    WB_start_i : in std_logic
 );
end WriteBack_Unit;

architecture RTL of WriteBack_Unit is
begin   

    comb_wb : process(all)
    begin  
        if WB_start_i = '0' then
            wr_rf_o <= '0';
            data_o <= (others => '0');
        else
            wr_rf_o <= '1';
            data_o <= data_i;
        end if;
    end process;


end RTL;
