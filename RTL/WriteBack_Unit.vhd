library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;



entity WriteBack_Unit is
Port (
    clk_i, rst_i : in std_logic;
    data_i : in std_logic_vector(31 downto 0);
    data_o : out std_logic_vector(31 downto 0);
    wr_rf_o : out std_logic; 
    IF_start_o : out std_logic;
    WB_start_i : in std_logic
 );
end WriteBack_Unit;

architecture RTL of WriteBack_Unit is
    signal IF_start : std_logic;
begin   

    comb_wb : process(all)
    begin  
        if WB_start_i = '0' then
            wr_rf_o <= '0';
            data_o <= (others => '0');
            IF_start <= '0';
        else
            wr_rf_o <= '1';
            data_o <= data_i;
            IF_start <= '1';
        end if;
    end process;

    reg_pipeline : process(clk_i, rst_i)
    begin  
        if rst_i = '1' then
            IF_start_o <= '0';
        elsif rising_edge(clk_i) then
            IF_start_o <= if_start;
        end if;
    end process;
end RTL;
