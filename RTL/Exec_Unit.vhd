library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity Exec_Unit is
Port ( 
    clk_i, rst_i, IE_start_i : in std_logic;

    --DECODE UNIT INTERFACE
    op1_i, op2_i : in std_logic_vector(31 downto 0);
    immediate_i : in std_logic_vector(31 downto 0);
    rd_i : in std_logic_vector(4 downto 0);
    rd_o : out std_logic_vector(4 downto 0);
    rs1_addr_i, rs2_addr_i : in std_logic_vector(4 downto 0);
    instr_numb_i : in std_logic_vector(5 downto 0);

    --WRITEBACK INTERFACE
    result_o : out std_logic_vector(31 downto 0);
    WB_start_o, br_update_o : out std_logic;

    --JUMP SIGNALS
    present_pc_i : in std_logic_vector(31 downto 0);
    jump_addr_o : out std_logic_vector(31 downto 0);

    --DATA MEMORY INTERFACE
    mem_data_i : in std_logic_vector(31 downto 0);
    mem_data_o : out std_logic_vector(31 downto 0);
    mem_we_o : out std_logic_vector(3 downto 0);
    mem_addr_o : out std_logic_vector(31 downto 0)
);
end Exec_Unit;

architecture RTL of Exec_Unit is
    signal result, op1, op2 : std_logic_vector(31 downto 0);
    signal imm : std_logic_vector(31 downto 0);
    signal shamt : std_logic_vector(4 downto 0);
    signal shift_enc : std_logic_vector(6 downto 0);
    signal WB_start : std_logic;
    signal jump_addr : std_logic_vector(31 downto 0);
    signal br_update : std_logic;
    signal mem_we : std_logic_vector(3 downto 0);
    signal mem_addr : std_logic_vector(31 downto 0);
    signal mem_data :  std_logic_vector(31 downto 0);
    --BYPASS SIGNALS
    signal bypass1, bypass2 : std_logic;
    signal rd_prev : std_logic_vector(4 downto 0);
begin
    --op2 <= op2_i;
    imm <= immediate_i;
    shamt <= immediate_i(4 downto 0);
    shift_enc <= immediate_i(11 downto 5);
    
    comb_exec : process(all) 
    begin
        if IE_start_i = '0' then
            result <= (others => '0');
            WB_start <= '0';
            br_update <= '0';
            mem_data <= (others => '0');
            jump_addr <= (others => '0');
            mem_we <= (others => '0');
            mem_addr <= (others => '0');
        else 
            WB_start <= '1';    
            br_update <= '0';
            result <= (others => '0');
            jump_addr <= (others => '0');  
            mem_we <= (others => '0');
            mem_data <= (others => '0');
            mem_addr <= (others => '0');  
            case instr_numb_i is
                when "000001" =>
                    result <= std_logic_vector(signed(op1) + signed(imm));
                when "000011" =>
                    if signed(op1) < signed(imm) then
                        result <= std_logic_vector(to_signed(1, 32));
                    else 
                        result <= (others => '0');
                    end if;
                when "000100" =>
                    if unsigned(op1) < unsigned(imm) then
                        result <= std_logic_vector(to_signed(1, 32));
                    else 
                        result <= (others => '0');
                    end if;
                when "001001" =>
                    result <= op1 and imm;
                when "001000" =>
                    result <= op1 or imm;
                when "000101" =>
                    result <= op1 xor imm;
                when "000010" =>
                    result <= std_logic_vector(unsigned(op1) sll to_integer(unsigned(shamt)));
                when "000110" =>
                    result <= std_logic_vector(unsigned(op1) srl to_integer(unsigned(shamt)));
                when "000111" =>
                    result <= std_logic_vector(signed(op1) sra  to_integer(unsigned(shamt)));

                when "001010" => -- R-Instr
                    result <= std_logic_vector(signed(op1) + signed(op2)); --ADD rd, rs1, rs2
                when "001011" => 
                    result <= std_logic_vector(signed(op1) - signed(op2)); -- SUB rd, rs1, rs2
                when "001101" => 
                    if signed(op1) < signed(op2) then
                        result <= std_logic_vector(to_signed(1, 32));
                    else 
                        result <= (others => '0');
                    end if;
                when "001110" =>
                    if unsigned(op1) < unsigned(op2) then
                        result <= std_logic_vector(to_signed(1, 32));
                    else 
                        result <= (others => '0');
                    end if;
                when "010011" => 
                    result <= op1 and op2;
                when "010010" =>
                    result <= op1 or op2; 
                when "001111" =>
                    result <= op1 xor op2;
                when "001100" => 
                    result <= std_logic_vector(unsigned(op1) sll to_integer(unsigned(op2)));
                when "010000" =>
                    result <= std_logic_vector(unsigned(op1) srl to_integer(unsigned(op2)));
                when "010001" =>
                    result <= std_logic_vector(signed(op1) sra to_integer(unsigned(op2)));
                when "010100" => -- JAL-Instr
                    result <= std_logic_vector(unsigned(present_pc_i) + 4); -- JAL rd, offset
                when "010101" => 
                    result <= std_logic_vector(unsigned(present_pc_i) + 4); -- JALR rd, rs1, offset
                    jump_addr <= std_logic_vector(unsigned(op1) + unsigned(imm));
                    br_update <= '1';
                when "010110" => 
                    if unsigned(op1) = unsigned(op2) then --BEQ
                        br_update <= '1';
                        jump_addr <= std_logic_vector(signed(present_pc_i) + signed(imm));
                        result <= (others => '0');
                    else 
                        br_update <= '0';
                        jump_addr <= (others => '0');
                        result <= (others => '0');
                    end if;
                when "010111" => 
                    if unsigned(op1) /= unsigned(op2) then --BNE
                        br_update <= '1';
                        jump_addr <= std_logic_vector(signed(present_pc_i) + signed(imm));
                        result <= (others => '0');
                    else 
                        br_update <= '0';
                        jump_addr <= (others => '0');
                        result <= (others => '0');
                    end if;
                when "011000" => 
                    if signed(op1) < signed(op2) then --BLT
                        br_update <= '1';
                        jump_addr <= std_logic_vector(signed(present_pc_i) + signed(imm));
                        result <= (others => '0');
                    else 
                        br_update <= '0';
                        jump_addr <= (others => '0');
                        result <= (others => '0');
                    end if;
                when "011001" => 
                    if signed(op1) >= signed(op2) then --BGE
                        br_update <= '1';
                        jump_addr <= std_logic_vector(signed(present_pc_i) + signed(imm));
                        result <= (others => '0');
                    else 
                        br_update <= '0';
                        jump_addr <= (others => '0');
                        result <= (others => '0');
                    end if;   
                when "011010" => 
                    if unsigned(op1) < unsigned(op2) then --BLTU
                        br_update <= '1';
                        jump_addr <= std_logic_vector(signed(present_pc_i) + signed(imm));
                        result <= (others => '0');
                    else 
                        br_update <= '0';
                        jump_addr <= (others => '0');
                        result <= (others => '0');
                    end if;     
                when "011011" => 
                    if unsigned(op1) >= unsigned(op2) then --BGEU
                        br_update <= '1';
                        jump_addr <= std_logic_vector(signed(present_pc_i) + signed(imm));
                        result <= (others => '0');
                    else 
                        br_update <= '0';
                        jump_addr <= (others => '0');
                        result <= (others => '0');
                    end if;     
                when "011100" => --LB   
                    mem_addr <= std_logic_vector(signed(op1) + signed(imm)); 
                    result <= (31 downto 8 => mem_data_i(7)) & mem_data_i(7 downto 0);
                when "011101" => --LH
                    mem_addr <= std_logic_vector(signed(op1) + signed(imm)); 
                    result<= (31 downto 16 => mem_data_i(15)) & mem_data_i(15 downto 0);
                when "011110" => --LW
                    mem_addr <= std_logic_vector(signed(op1) + signed(imm)); 
                    result <= mem_data_i(31 downto 0);
                when "011111" => --LBU
                    mem_addr <= std_logic_vector(signed(op1) + signed(imm)); 
                    result <= (31 downto 8 => '0') & mem_data_i(7 downto 0); 
                when "100000" =>  --LHU     
                    mem_addr <= std_logic_vector(signed(op1) + signed(imm));  
                    result <= (31 downto 16 => '0') & mem_data_i(15 downto 0);
                when "100001" => --SB
                    mem_addr <= std_logic_vector(signed(op1) + signed(imm));
                    mem_we <= "0001";
                    mem_data <=  (31 downto 8 => '0') & op2(7 downto 0); 
                when "100010" =>  --SH
                    mem_addr <= std_logic_vector(signed(op1) + signed(imm));
                    mem_we <= "0010";
                    mem_data <= (31 downto 16 => '0') & op2(15 downto 0);
                when "100011" =>
                    mem_addr <= std_logic_vector(signed(op1) + signed(imm));
                    mem_we <= "1111";
                    mem_data <= op2;   
                when others => 
                    result <= (others => '0');
                end case;
        end if;
    end process;

-- BYPASS LOGIC -------------------------------------

    process(clk_i)
    begin 
        if rising_Edge(clk_i) then
            rd_prev <= rd_i;
        end if;
    end process;

bypass1 <= '1' when rd_prev = rs1_addr_i else '0';
bypass2 <= '1' when rd_prev = rs2_addr_i else '0';
op2 <= op2_i when bypass2= '0' else result_o;
op1 <= op1_i when bypass1 = '0' else result_o;

-------------------------------------------------------
    reg_pipeline : process(clk_i, rst_i)
    begin
        if rst_i = '1' then
            result_o <= (others => '0');
            WB_start_o <= '0';
            rd_o <= (others => '0');
            br_update_o <= '0';
            jump_addr_o <= (others => '0');
            mem_we_o <= (others => '0');
            mem_addr_o <= (others => '0');
        elsif rising_Edge(clk_i) then
            result_o <= result;
            WB_start_o <= WB_start;
            rd_o <= rd_i;
            mem_we_o <= mem_we;
            mem_addr_o <= mem_addr;
            mem_data_o <= mem_data;
            jump_addr_o <= jump_addr;
            br_update_o <= br_update;
        end if;
    end process;
end RTL;
