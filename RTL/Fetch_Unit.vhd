library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.sp_pkg.all;


entity Fetch_unit is
Port ( 
    fetch_req_o : out std_logic;
    PC : in std_logic_vector(31 downto 0);
    PC_IF : out std_logic_vector(31 downto 0);
    pc_update_o : out std_logic;
    IF_start_i : in std_logic;
    clk_i, rst_i : in std_logic;
    lsu_busy : in std_logic;
    instr_i : in std_logic_vector(31 downto 0);
    stall_o : out std_logic;
    ID_start_o : out std_logic;
    instr_o : out std_logic_vector(31 downto 0)
);
end Fetch_unit;

architecture RTL of Fetch_unit is
    signal instr_fetched: std_logic_vector(31 downto 0);
    signal id_start : std_logic;
    signal IF_enable : std_logic;
    signal NOP_instr : std_logic_vector(31 downto 0) := "00000000000000000000000000010011";
    signal stall : std_logic;
begin 
    instr_fetched <= instr_i;
    IF_enable <= IF_start_i and (not lsu_busy);
    --stall_o <= stall;
    comb_fetch : process(all) 
    begin
        if IF_enable = '1' then
            fetch_req_o <= '1';
            id_start <= '1';
            pc_update_o <= '1';
        else 
            fetch_req_o <= '0';
            id_start <= '0';
            pc_update_o <= '0';
        end if;
    end process;
    
    process(clk_i) begin
        if rising_edge(clk_i) then
            if lsu_busy = '0' then
                stall_o <= '0';
            else 
                stall_o <= '1';
            end if;
        end if;
    end process;


    reg_pipeline : process(clk_i, rst_i) 
    begin
        if rst_i = '1' then
            instr_o <= (others => '0');
            id_start_o <= '0';
            PC_IF <= (others => '0');
        elsif rising_edge(clk_i) then
            id_start_o <= id_start;
            PC_IF <= PC;
            if IF_enable = '1' then
                instr_o <= instr_fetched;
            else 
                instr_o <= NOP_instr;
            end if;
        end if;
    end process;
    
end RTL;
