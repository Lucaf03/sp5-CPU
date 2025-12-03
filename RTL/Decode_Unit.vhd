library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.sp_pkg.all;

entity Decode_Unit is
Port ( 
    instr_i : in std_logic_vector(31 downto 0);
    ID_start_i : IN STD_logic;
    IE_start_o : out std_logic;
    PC_IF : in std_logic_vector(31 downto 0);
    PC_ID : out std_logic_vector(31 downto 0);
    clk_i, rst_i : in std_logic;
    stall_i : in std_logic;
    instr_decoded_o : out INSTR_NAME;
    immediate_o : out std_logic_vector(31 downto 0);
    lsu_busy : out std_logic;
    bypass1_o, bypass2_o : out std_logic;
    rs1_addr_o, rs2_addr_o, rd_addr_o : out std_logic_vector(4 downto 0);
    CSR_start_o : out std_logic;
    csr_addr_o : out std_logic_vector(11 downto 0)
);
end Decode_Unit;

architecture RTL of Decode_Unit is
    signal opcode : std_logic_vector(6 downto 0);
    signal rs1, rs2, rd : std_logic_vector(4 downto 0);
    signal imm : std_logic_vector(31 downto 0);
    signal funct3 : std_logic_vector(2 downto 0);
    signal funct7 : std_logic_vector(6 downto 0);
    signal IE_start : std_logic;
    signal instr_decoded : INSTR_NAME;
    signal bypass1, bypass2 : std_logic;
    signal rd_prev : std_logic_vector(4 downto 0);

    signal csr_start : std_logic;
    signal csr_addr : std_logic_vector(11 downto 0);
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
            instr_decoded <= NOP;   
            lsu_busy <= '0';  
            csr_start <= '0';
            csr_addr <= (others => '0');
        else   
            IE_start <= '0'; 
            rd <= (others  => '0');
            rs1 <= (others  => '0');
            rs2 <= (others  => '0');
            imm <= (others  => '0'); 
            lsu_busy <= '0';
            csr_start <= '0';
            csr_addr <= (others => '0');
            case opcode is
                    when "0010011" => --Immediate-Instructions
                        IE_start <= '1';
                        rd <= instr_i(11 downto 7);
                        rs1 <= instr_i(19 downto 15);
                        imm <= (31 downto 12 => instr_i(31)) & instr_i(31 downto 20);  
                        case funct3 is 
                            when "000" => instr_decoded <= ADDI; --ADDI
                            when "001" => instr_decoded <= SLLI; --SLLI
                            when "010" => instr_decoded <= SLTI; --SLTI
                            when "011" => instr_decoded <= SLTIU; --SLTIU
                            when "100" => instr_decoded <= XORI; --XORI
                            when "101" =>  
                                if funct7(6 downto 1) = "000000" then
                                    instr_decoded <= SRLI; --SRLI
                                else 
                                    instr_decoded <= SRAI; --SRAI
                                end if; 
                            when "110" => instr_decoded <= ORI; --ORI
                            when "111" => instr_decoded <= ANDI; --ANDI
                            when others => instr_decoded <= NOP;
                        end case;
                    when "0110011" => --Register-To-Register-Instructions and M-Instructions
                        IE_start <= '1';
                        rd <= instr_i(11 downto 7);
                        rs1 <= instr_i(19 downto 15);
                        rs2 <= instr_i(24 downto 20); 
                        case funct3 is 
                            when "000" =>
                                if funct7 = "0000000" then
                                    instr_decoded <= ADD; --ADD
                                elsif funct7 = "0000001" then
                                    instr_decoded <= MUL;
                                else 
                                    instr_decoded <= SUB; --SUB
                                end if; 
                            when "001" => 
                                if funct7 = "0000001" then
                                    instr_decoded <= MULH;
                                else
                                    instr_decoded <= SLLR; --SLL
                                end if;
                            when "010" => 
                                if funct7 = "0000001" then
                                    instr_decoded <= MULHSU;
                                else 
                                    instr_decoded <= SLT; --SLT
                                end if;
                            when "011" => 
                                if funct7 = "0000001" then
                                    instr_decoded <= MULHU;
                                else  
                                    instr_decoded <= SLTU; --SLTU
                                end if;
                            when "100" => instr_decoded <= XORR; --XOR
                            when "101" =>
                                if funct7 = "0000000" then
                                    instr_decoded <= SRLR; --SRL
                                else 
                                    instr_decoded <= SRAR; --SRA
                                end if;  
                            when "110" => instr_decoded <= ORR; --OR
                            when "111" => instr_decoded <= ANDR; --AND
                            when others => instr_decoded <= NOP;
                        end case;
                    when "1101111" => --JAL-Instructions
                        IE_start <= '1';
                        rd <= instr_i(11 downto 7);
                        instr_decoded <= JAL;
                    when "1100111" => --JALR-Instructions
                        IE_start <= '1';
                        rd <= instr_i(11 downto 7);
                        rs1 <= instr_i(19 downto 15);
                        imm <= (31 downto 12 => instr_i(31)) & instr_i(31 downto 20);
                        instr_decoded <= JALR;
                    when "1100011" => --BRANCH instructions
                        IE_start <= '1';
                        rs1 <= instr_i(19 downto 15);
                        rs2 <= instr_i(24 downto 20);
                        rd <= (others => '0');
                        imm <= (31 downto 12 => instr_i(31)) & instr_i(7) & instr_i(30 downto 25) & instr_i(11 downto 8) & '0';
                        case funct3 is 
                            when "000" =>
                                instr_decoded <= BEQ;
                            when "001" =>
                                instr_decoded <= BNE;
                            when "100" =>
                                instr_decoded <= BLT;
                            when "101" =>
                                instr_decoded <= BGE;
                            when "110" =>
                                instr_decoded <= BLTU;
                            when "111" =>
                                instr_decoded <= BGEU;
                            when others =>
                                instr_decoded <= NOP;
                        end case;
                    when "0000011" => --LOAD INSTRUNCTIONS
                        IE_start <= '1';
                        lsu_busy <= '1';
                        rd <= instr_i(11 downto 7);
                        rs1 <= instr_i(19 downto 15);
                        imm <= (31 downto 12 => instr_i(31)) & instr_i(31 downto 20);
                        case funct3 is 
                            when "000" => 
                                instr_decoded <= LB;
                            when "001" => 
                                instr_decoded <= LH;
                            when "010" => 
                                instr_decoded <= LW;
                            when "100" => 
                                instr_decoded <= LBU;
                            when "101" =>
                                instr_decoded <= LHU;
                            when others =>
                                instr_decoded <= NOP;
                        end case;
                    when "0100011" => --STORE INSTRUNCTIONS
                        IE_start <= '1';
                        lsu_busy <= '1';
                        rs1 <= instr_i(19 downto 15);
                        rs2 <= instr_i(24 downto 20);
                        imm <= (31 downto 12 => instr_i(31)) & instr_i(31 downto 25) & instr_i(11 downto 7);
                        case funct3 is 
                            when "000" => 
                                instr_decoded <= SB;
                            when "001" =>
                                instr_decoded <= SH;
                            when "010" =>
                                instr_decoded <= SW;
                            when others =>
                                instr_decoded <= NOP;
                        end case;
                    when "0110111" => --LOAD UPPER IMMEDIATE 
                        IE_start <= '1';
                        rd <= instr_i(11 downto 7);
                        imm <= instr_i(31 downto 12) & (11 downto 0 => '0');
                        instr_decoded <= LUI;
                    when "0010111" => --AUIPC
                        IE_start <= '1';
                        rd <= instr_i(11 downto 7);
                        imm <= instr_i(31 downto 12) & (11 downto 0 => '0');
                        instr_decoded <= AUIPC;

--------------------CSR INSTRUNCTIONS-----------------------------------------------------------------
                    when "1110011" =>
                        csr_start <= '1';
                        rd <= instr_i(11 downto 7);
                        rs1 <= instr_i(19 downto 15);
                        csr_addr <= instr_i(31 downto 20);
                            case funct3 is 
                                when "001" => 
                                    instr_decoded <= CSRRW;
                                when "010" =>
                                    instr_decoded <= CSRRS;
                                when "011" => 
                                    instr_decoded <= CSRRC;
                                when "101" => 
                                    instr_decoded <= CSRRWI;
                                when "110" =>
                                    instr_decoded <= CSRRSI;
                                when "111" => 
                                    instr_decoded <= CSRRCI;
                                when others => 
                                    csr_start <= '0';
                                    instr_decoded <= NOP;
                            end case;

                    when others => 
                        rd <= (others  => '0');
                        rs1 <= (others  => '0');
                        rs2 <= (others  => '0');
                        imm <= (others  => '0');
                        instr_decoded <= NOP;
                        csr_start <= '0';
            end case;
        end if;
    end process;

    process(clk_i)
    begin 
        if rising_Edge(clk_i) then
            rd_prev <= rd;
        end if;
    end process;

    bypass1 <= '1' when rd_prev = rs1 else '0';
    bypass2 <= '1' when rd_prev = rs2 else '0';


    reg_pipeline : process(clk_i, rst_i)
    begin
        if rst_i = '1' then
            bypass1_o <= '0';
            bypass2_o <= '0';
            rd_addr_o <= (others  => '0');
            rs1_addr_o <= (others  => '0');
            rs2_addr_o <= (others  => '0');
            IE_start_o <= '0';
            immediate_o <= (others => '0');
            instr_decoded_o <= NOP;
            PC_ID <= (others => '0');
            CSR_start_o <= '0';
            csr_addr_o <= (others => '0');
        elsif rising_edge(clk_i) then
            IE_start_o <= ie_start;
            instr_decoded_o <= instr_decoded;
            PC_ID <= PC_IF;
            bypass1_o <= bypass1;
            bypass2_o <= bypass2;
            CSR_start_o <= csr_start;
            csr_addr_o <= csr_addr;
            if stall_i = '0' then
                rs1_addr_o <= rs1;
                rs2_addr_o <= rs2;
                rd_addr_o <= rd;
                immediate_o <= imm;
            else 
                rd_addr_o <= (others  => '0');
                rs1_addr_o <= (others  => '0');
                rs2_addr_o <= (others  => '0');
                immediate_o <= (others => '0');
            end if;
        end if;
    end process;
end RTL;
