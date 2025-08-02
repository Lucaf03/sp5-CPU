library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity Fetch_unit is
Port ( 
    fetch_req_o : out std_logic;
    present_pc_i : in std_logic_vector(31 downto 0);
    present_pc_o : out std_logic_vector(31 downto 0);
    pc_update_o, br_update_o : out std_logic;
    IF_start_i : in std_logic;
    clk_i, rst_i : in std_logic;
    instr_i : in std_logic_vector(31 downto 0);
    ID_start_o, is_jal_o : out std_logic;
    instr_o, jump_addr_o: out std_logic_vector(31 downto 0)
);
end Fetch_unit;

architecture RTL of Fetch_unit is
    signal instr_fetched: std_logic_vector(31 downto 0);
    signal id_start : std_logic;
    --constant nop_instr : std_logic_vector(31 downto 0) := "00000000000000000000000000010011";
    signal jump_addr : std_logic_vector(31 downto 0);
    signal is_jal : std_logic;
begin 
    instr_fetched <= instr_i;
    jump_addr_o <= jump_addr;
    is_jal_o <= is_jal;

    is_jal <= '1' when instr_fetched(6 downto 0) = "1101111" else '0';
    
    comb_fetch : process(all) 
    variable jal_rd : std_logic_vector(4 downto 0);
    variable jal_imm : std_logic_vector(20 downto 0);
    variable jal_addr : std_logic_vector(31 downto 0);
    begin
        if IF_start_i = '1' then
                fetch_req_o <= '1';
                id_start <= '1';
            if is_jal = '1' then --JAL
                pc_update_o <= '0';
                br_update_o <= '1' ;
                jal_imm := (instr_fetched(31) & instr_fetched(19 downto 12) & instr_fetched(20) & instr_fetched(30 downto 21) & '0');
                jal_addr :=  (31 downto 21 => jal_imm(20)) & jal_imm;
                jump_addr <= std_logic_vector(signed(present_pc_i) + signed(jal_addr) );
            else 
                pc_update_o <= '1';
                br_update_o <= '0' ;
                   jump_addr <=(others => '0');
            end if;
        else 
            fetch_req_o <= '0';
            id_start <= '0';
            jump_addr <= (others => '0');
            pc_update_o <= '0';
            br_update_o <= '0' ;
        end if;
    end process;
    
    reg_pipeline : process(clk_i, rst_i) 
    begin
        if rst_i = '1' then
            instr_o <= (others => '0');
            id_start_o <= '0';
            present_pc_o <= (others => '0');
        elsif rising_edge(clk_i) then
            id_start_o <= id_start;
            present_pc_o <= present_pc_i;
            instr_o <= instr_fetched;
        end if;
    end process;
    
end RTL;
