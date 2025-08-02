library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Register_file is
Port (
    rs1_addr_i, rs2_addr_i : in std_logic_vector(4 downto 0);
    op1_o, op2_o : out std_logic_vector(31 downto 0);
    wr_data_i : in std_logic_vector(31 downto 0);
    wr_enb : in std_logic;
    clk_i, rst_i : in std_logic;
    rd_i : in std_logic_vector(4 downto 0)
 );
end Register_file;

architecture RTL of Register_file is
    type reg_file_t is array(31 downto 0) of std_logic_vector(31 downto 0);
    signal reg_file : reg_file_t;
begin
    
    
    process(clk_i, rst_i)
    begin
        if rst_i = '1' then
            for i in 0 to 31 loop
                reg_file(i) <= (others => '0');
            end loop;
        elsif rising_edge(clk_i) then
            if wr_enb = '1' then
                if rd_i /= std_logic_vector(to_unsigned(0,5)) then                 
                    reg_file(to_integer(unsigned(rd_i))) <= wr_data_i;
                end if;
            end if;
        end if;
    end process;
    
    op1_o <= reg_file(to_integer(unsigned(rs1_addr_i)));
    op2_o <= reg_file(to_integer(unsigned(rs2_addr_i)));
end RTL;
