library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity Decode_Unit is
Port ( 
    instr_i : in std_logic_vector(31 downto 0);
    ID_start_i : IN STD_logic;
    IE_start_o : out std_logic;
    present_pc_i : in std_logic_vector(31 downto 0);
    present_pc_o : out std_logic_vector(31 downto 0);
    clk_i, rst_i : in std_logic;
    instr_numb_o : out std_logic_vector(5 downto 0);
    immediate_o : out std_logic_vector(31 downto 0);
    rs1_addr_o, rs2_addr_o, rd_addr_o : out std_logic_vector(4 downto 0)
);
end Decode_Unit;

architecture RTL of Decode_Unit is
    signal opcode : std_logic_vector(6 downto 0);
    signal rs1, rs2, rd : std_logic_vector(4 downto 0);
    signal imm : std_logic_vector(31 downto 0);
    signal funct3 : std_logic_vector(2 downto 0);
    signal funct7 : std_logic_vector(6 downto 0);
    signal IE_start : std_logic;
    signal instr_numb : std_logic_vector(5 downto 0);
begin
    opcode <= instr_i(6 downto 0);
    funct3 <= instr_i(14 downto 12); 
    funct7 <= instr_i(31 downto 25);

    comb_dec : process(all) 
    begin
        if ID_start_i = '0' then
            rd <= (others  => '0');
            rs1 <= (others  => '0');
            rs2 <= (others  => '0');
            imm <= (others  => '0');            
            IE_start <= '0';  
            instr_numb <= (others => '0');     
        else   
            IE_start <= '1';
            rd <= (others  => '0');
            rs1 <= (others  => '0');
            rs2 <= (others  => '0');
            imm <= (others  => '0'); 
            case opcode is
                    when "0010011" => --Immediate-Instructions
                        rd <= instr_i(11 downto 7);
                        rs1 <= instr_i(19 downto 15);
                        imm <= (31 downto 12 => instr_i(31)) & instr_i(31 downto 20);  
                        case funct3 is 
                            when "000" => instr_numb <= "000001"; --ADDI
                            when "001" => instr_numb <= "000010"; --SLLI
                            when "010" => instr_numb <= "000011"; --SLTI
                            when "011" => instr_numb <= "000100"; --SLTIU
                            when "100" => instr_numb <= "000101"; --XORI
                            when "101" =>  
                                if funct7(6 downto 1) = "000000" then
                                    instr_numb <= "000110"; --SRLI
                                else 
                                    instr_numb <= "000111"; --SRAI
                                end if; 
                            when "110" => instr_numb <= "001000"; --ORI
                            when "111" => instr_numb <= "001001"; --ANDI
                            when others => instr_numb <= (others => '0');
                        end case;
                    when "0110011" => --Register-To-Register-Instructions
                        rd <= instr_i(11 downto 7);
                        rs1 <= instr_i(19 downto 15);
                        rs2 <= instr_i(24 downto 20); 
                        case funct3 is 
                            when "000" =>
                                if funct7 = "0000000" then
                                    instr_numb <= "001010"; --ADD
                                else 
                                    instr_numb <= "001011"; --SUB
                                end if; 
                            when "001" => instr_numb <= "001100"; --SLL
                            when "010" => instr_numb <= "001101"; --SLT
                            when "011" => instr_numb <= "001110"; --SLTU
                            when "100" => instr_numb <= "001111"; --XOR
                            when "101" =>
                                if funct7 = "0000000" then
                                    instr_numb <= "010000"; --SRL
                                else 
                                    instr_numb <= "010001"; --SRA
                                end if;  
                            when "110" => instr_numb <= "010010"; --OR
                            when "111" => instr_numb <= "010011"; --AND
                            when others => instr_numb <= (others => '0');
                        end case;
                    when "1101111" => --JAL-Instructions
                        rd <= instr_i(11 downto 7);
                        instr_numb <= "010100";
                    when "1100111" => --JALR-Instructions
                        rd <= instr_i(11 downto 7);
                        rs1 <= instr_i(19 downto 15);
                        imm <= (31 downto 12 => instr_i(31)) & instr_i(31 downto 20);
                        instr_numb <= "010101";
                    when "1100011" => --BRANCH instructions
                        rs1 <= instr_i(19 downto 15);
                        rs2 <= instr_i(24 downto 20);
                        rd <= (others => '0');
                        imm <= (31 downto 12 => instr_i(31)) & instr_i(7) & instr_i(30 downto 25) & instr_i(11 downto 8) & '0';
                        case funct3 is 
                            when "000" =>
                                instr_numb <= "010110";
                            when "001" =>
                                instr_numb <= "010111";
                            when "100" =>
                                instr_numb <= "011000";
                            when "101" =>
                                instr_numb <= "011001";
                            when "110" =>
                                instr_numb <= "011010";
                            when "111" =>
                                instr_numb <= "011011";
                            when others =>
                                instr_numb <= (others => '0');
                        end case;
                    when "0000011" => --LB/LH/LW/LBU/LHU
                        rd <= instr_i(11 downto 7);
                        rs1 <= instr_i(19 downto 15);
                        imm <= (31 downto 12 => instr_i(31)) & instr_i(31 downto 20);
                        case funct3 is 
                            when "000" => 
                                instr_numb <= "011100";
                            when "001" => 
                                instr_numb <= "011101";
                            when "010" => 
                                instr_numb <= "011110";
                            when "100" => 
                                instr_numb <= "011111";
                            when "101" =>
                                instr_numb <= "100000";
                            when others =>
                                instr_numb <= (others => '0');
                        end case;
                    when "0100011" => --SB/SH/SW
                        rs1 <= instr_i(19 downto 15);
                        rs2 <= instr_i(24 downto 20);
                        imm <= (31 downto 12 => instr_i(31)) & instr_i(31 downto 25) & instr_i(11 downto 7);
                        case funct3 is 
                            when "000" => 
                                instr_numb <= "100001";
                            when "001" =>
                                instr_numb <= "100010";
                            when "010" =>
                                instr_numb <= "100011";
                            when others =>
                                instr_numb <= (others => '0');
                        end case;
                    when others => 
                        rd <= (others  => '0');
                        rs1 <= (others  => '0');
                        rs2 <= (others  => '0');
                        imm <= (others  => '0');
                        instr_numb <= (others => '0');
            end case;
        end if;
    end process;

    reg_pipeline : process(clk_i, rst_i)
    begin
        if rst_i = '1' then
            rd_addr_o <= (others  => '0');
            rs1_addr_o <= (others  => '0');
            rs2_addr_o <= (others  => '0');
            IE_start_o <= '0';
            immediate_o <= (others => '0');
            present_pc_o <= (others => '0');
            instr_numb_o <= (others => '0');
        elsif rising_edge(clk_i) then
            rs1_addr_o <= rs1;
            rs2_addr_o <= rs2;
            rd_addr_o <= rd;
            IE_start_o <= ie_start;
            immediate_o <= imm;
            present_pc_o <= present_pc_i;
            instr_numb_o <= instr_numb;
        end if;
    end process;
end RTL;
