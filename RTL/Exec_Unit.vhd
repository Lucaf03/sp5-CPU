library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.sp_pkg.all;

--TODO-FUTURE: DIVISIONS

entity Exec_Unit is
Port ( 
    clk_i, rst_i, IE_start_i : in std_logic;
    --lsu_busy : out std_logic;
    --DECODE UNIT INTERFACE
    op1_i, op2_i : in std_logic_vector(31 downto 0);
    immediate_i : in std_logic_vector(31 downto 0);
    rd_i : in std_logic_vector(4 downto 0);
    rd_o : out std_logic_vector(4 downto 0);
    rs1_addr_i, rs2_addr_i : in std_logic_vector(4 downto 0);
    instr_decoded_i : in INSTR_NAME;
    bypass1, bypass2 : in std_logic;
    --WRITEBACK INTERFACE
    result_o : out std_logic_vector(31 downto 0);
    WB_start_o, br_update_o : out std_logic;

    --JUMP SIGNALS
    PC_ID : in std_logic_vector(31 downto 0);
    PC_IE : out std_logic_vector(31 downto 0);
    jump_addr_o : out std_logic_vector(31 downto 0);

    --DATA MEMORY INTERFACE
    mem_en_o : out std_logic;
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
    signal WB_enb : std_logic;
    signal jump_addr : std_logic_vector(31 downto 0);
    signal br_update : std_logic;
    signal mem_en : std_logic;
    signal mem_we : std_logic_vector(3 downto 0);
    signal mem_addr, addr : std_logic_vector(31 downto 0);
    signal mem_data :  std_logic_vector(31 downto 0);
    --BYPASS SIGNALS

    signal mem_load : std_logic_vector(31 downto 0);

    signal add_A, add_B : std_logic_vector(31 downto 0);
    signal and_A, and_B : std_logic_vector(31 downto 0);
    signal or_A, or_B : std_logic_vector(31 downto 0);
    signal xor_A, xor_B : std_logic_vector(31 downto 0);
    signal slt_A, slt_B : std_logic_vector(31 downto 0);
    signal sll_A, sll_B : std_logic_vector(31 downto 0);
    signal srl_A, srl_B : std_logic_vector(31 downto 0);
    signal sra_A, sra_B : std_logic_vector(31 downto 0);
    signal mem_A, mem_B : std_logic_vector(31 downto 0);
    signal branch_taken : std_logic;

    signal mul_enb : std_logic;
    signal mul_result : std_logic_vector(65 downto 0);
    signal mul_A, mul_B : std_logic_vector(32 downto 0); --1 bit for the sign
begin
    --op2 <= op2_i;
    imm <= immediate_i;
    shamt <= immediate_i(4 downto 0);
    shift_enc <= immediate_i(11 downto 5);
    mem_load <= mem_data_i;

    comb_exec : process(all) 
    begin

        if IE_start_i = '0' then
            result <= (others => '0');
            WB_enb <= '0';
            br_update <= '0';
            mem_data <= (others => '0');
            jump_addr <= (others => '0');
            mem_we <= (others => '0');
            addr <= (others => '0');
            mul_enb <= '0';
        else 
            WB_enb <= '1';    
            br_update <= '0';
            result <= (others => '0');
            jump_addr <= (others => '0');  
            mem_we <= (others => '0');
            mem_data <= (others => '0');
            addr <= (others => '0');
            mul_enb <= '0';

            if (instr_decoded_i = ADDI or instr_decoded_i = ADD or instr_decoded_i = SUB or 
                instr_decoded_i = JAL or instr_decoded_i = JALR or instr_decoded_i = AUIPC) then
                result <= std_logic_vector(signed(add_A) + signed(add_B));
            end if;

            if (instr_decoded_i = ANDI or instr_decoded_i = ANDR) then
                result <= and_A and and_B;
            end if;

            if (instr_decoded_i = ORI or instr_decoded_i = ORR) then
                result <= or_A or or_B;
            end if;

            if (instr_decoded_i = XORI or instr_decoded_i = XORR) then
                result <= xor_A xor xor_B;
            end if;

            if (instr_decoded_i = SLTI or instr_decoded_i = SLT) then
                if signed(slt_A) < signed(slt_B) then
                    result <= std_logic_vector(to_signed(1, 32));
                else 
                    result <= (others => '0');
                end if;
            end if;

            if (instr_decoded_i = SLTIU or instr_decoded_i = SLTU) then
                if unsigned(slt_A) < unsigned(slt_B) then
                    result <= std_logic_vector(to_signed(1, 32));
                else 
                    result <= (others => '0');
                end if;
            end if; 

            if (instr_decoded_i = SLLI or instr_decoded_i = SLLR) then
                result <= std_logic_vector(unsigned(sll_A) sll to_integer(unsigned(sll_B)));
            end if;

            if (instr_decoded_i = SRLI or instr_decoded_i = SRLR) then
                result <= std_logic_vector(unsigned(srl_A) srl to_integer(unsigned(srl_B)));
            end if;         

            if (instr_decoded_i = SRAI or instr_decoded_i = SRAR) then
                result <= std_logic_vector(signed(sra_A) sra to_integer(unsigned(sra_B)));
            end if;  

            if instr_decoded_i = LUI then
                result <= imm;
            end if; 

            if instr_decoded_i = LB then 
                result <= (31 downto 8 => mem_load(7)) & mem_load(7 downto 0);
            end if;
            if instr_decoded_i = LH then
                result<= (31 downto 16 => mem_load(15)) & mem_load(15 downto 0);
            end if;
            if instr_decoded_i = LW then
                result <= mem_load(31 downto 0);
            end if; 
            if instr_decoded_i = LBU then
                result <= (31 downto 8 => '0') & mem_load(7 downto 0);
            end if;
            if instr_decoded_i = LHU then
                result <= (31 downto 16 => '0') & mem_load(15 downto 0);
            end if;

            if instr_decoded_i = SB then
                mem_we <= "0001";
                mem_data <=  (31 downto 8 => '0') & op2(7 downto 0); 
            end if;
            if instr_decoded_i = SH then
                mem_we <= "0010";
                mem_data <= (31 downto 16 => '0') & op2(15 downto 0);
            end if;
            if instr_decoded_i = SW then
                mem_we <= "1111";
                mem_data <= op2;   
            end if;

            if (instr_decoded_i = LB or instr_decoded_i = LBU or 
                instr_decoded_i = LH or instr_decoded_i = LHU or
                instr_decoded_i = LW or instr_decoded_i = SW  or
                instr_decoded_i = SB or instr_decoded_i = SH) then
                addr <= std_logic_vector(unsigned(op1) + unsigned(imm));
            end if;

            if instr_decoded_i = JALR then
                jump_addr <= std_logic_vector(unsigned(op1) + unsigned(imm));
                br_update <= '1';
            end if;

            if (instr_decoded_i = BEQ or instr_decoded_i = BNE or
                instr_decoded_i = BLT or instr_decoded_i = BGE or 
                instr_decoded_i = BLTU or instr_decoded_i = BGEU) then
                if branch_taken = '1' then
                    br_update <= '1';
                    jump_addr <= std_logic_vector(signed(PC_ID) + signed(imm));
                end if;
            end if;

            if (instr_decoded_i = MULH or instr_decoded_i = MULHSU or instr_decoded_i = MULHU) then
                mul_enb <= '1';
                result <= mul_result(63 downto 32);
            end if;

            if (instr_decoded_i = MUL) then
                mul_enb <= '1';
                result <= mul_result(31 downto 0);
            end if;

        end if;
    end process;
-- MULTIPLIER ---------------------------------------
    
    process(all) begin
        if mul_enb = '1' then
            mul_result <= std_logic_vector(signed(mul_A) * signed(mul_B));          
        else 
            mul_result <= (others => '0');
        end if;

    end process;

-- MAPPER -------------------------------------------

    process(all)
    begin 
        add_A <= (others => '0');
        add_B <= (others => '0');
        and_A <= (others => '0');
        and_B <= (others => '0');
        or_A <= (others => '0');
        or_B <= (others => '0');
        xor_A <= (others => '0');
        xor_B <= (others => '0');
        slt_A <= (others => '0');
        slt_B <= (others => '0');
        sll_A <= (others => '0');
        sll_B <= (others => '0');
        srl_A <= (others => '0');
        srl_B <= (others => '0');
        sra_A <= (others => '0');
        sra_B <= (others => '0');
        branch_taken <= '0';
        mul_A <= (others => '0');
        mul_B <= (others => '0');


        if instr_decoded_i = ADDI then
            add_A <= op1;
            add_B <= imm;
        end if;

        if instr_decoded_i = ADD then
            add_A <= op1;
            add_B <= op2;
        end if;

        if instr_decoded_i = AUIPC then
            add_A <= PC_ID;
            add_B <= imm;
        end if;
        
        if instr_decoded_i = SUB then
            add_A <= op1;
            add_B <= std_logic_vector(unsigned(not(op2))+1); -- -op2
        end if;

        if instr_decoded_i = JAL or instr_decoded_i = JALR then
            add_A <= PC_ID;
            add_B <= std_logic_vector(to_unsigned(4, 32)); 
        end if;   

        if instr_decoded_i = ANDI then
            and_A <= op1;
            and_B <= imm;
        end if;

        if instr_decoded_i = ANDR then
            and_A <= op1;
            and_B <= op2;
        end if;

        if instr_decoded_i = ORI then
            or_A <= op1;
            or_B <= imm;
        end if;

        if instr_decoded_i = ORR then
            or_A <= op1;
            or_B <= op2;
        end if;

        if instr_decoded_i = XORI then
            xor_A <= op1;
            xor_B <= imm;
        end if;

        if instr_decoded_i = XORR then
            xor_A <= op1;
            xor_B <= op2;
        end if;

        if instr_decoded_i = SLTI or instr_decoded_i = SLTIU then 
            slt_A <= op1;
            slt_B <= imm;
        end if;

        if instr_decoded_i = SLT or instr_decoded_i = SLTU then 
            slt_A <= op1;
            slt_B <= op2;
        end if;

        if instr_decoded_i = SLLI then
            sll_A <= op1;
            sll_B <= (31 downto 5 => '0') & shamt;
        end if;

        if instr_decoded_i = SLLR then
            sll_A <= op1;
            sll_B <= op2;
        end if;

        if instr_decoded_i = SRLI then
            srl_A <= op1;
            srl_B <= (31 downto 5 => '0') & shamt;
        end if;

        if instr_decoded_i = SRLR then
            srl_A <= op1;
            srl_B <= op2;
        end if;

        if instr_decoded_i = SRAI then
            sra_A <= op1;
            sra_B <= (31 downto 5 => '0') & shamt;
        end if;

        if instr_decoded_i = SRAR then
            sra_A <= op1;
            sra_B <= op2;
        end if;

        if instr_decoded_i = BEQ then
            if unsigned(op1) = unsigned(op2) then
                branch_taken <= '1';
            else 
                branch_taken <= '0';
            end if;
        end if;

        if instr_decoded_i = BNE then
            if unsigned(op1) /= unsigned(op2) then
                branch_taken <= '1';
            else 
                branch_taken <= '0';
            end if;
        end if; 

        if instr_decoded_i = BLT then
            if signed(op1) < signed(op2) then
                branch_taken <= '1';
            else 
                branch_taken <= '0';
            end if;
        end if;         

        if instr_decoded_i = BGE then
            if signed(op1) >= signed(op2) then
                branch_taken <= '1';
            else 
                branch_taken <= '0';
            end if;
        end if;

        if instr_decoded_i = BLTU then
            if unsigned(op1) < unsigned(op2) then
                branch_taken <= '1';
            else 
                branch_taken <= '0';
            end if;
        end if; 

        if instr_decoded_i = BGEU then
            if unsigned(op1) >= unsigned(op2) then
                branch_taken <= '1';
            else 
                branch_taken <= '0';
            end if;
        end if;   

        if instr_decoded_i = MUL or instr_decoded_i = MULH then
            mul_A <= op1(31)&op1;
            mul_B <= op2(31)&op2;
        end if;

        if instr_decoded_i = MULHU then
            mul_A <= ('0'& op1);
            mul_B <= ('0'& op2);
        end if;

        if instr_decoded_i = MULHSU then
            mul_A <= op1(31)&op1;
            mul_B <= ('0'& op2);
        end if;
    end process;

-----------------------------------------------------
-- BYPASS LOGIC -------------------------------------

op2 <= op2_i when bypass2 = '0' else result_o;
op1 <= op1_i when bypass1 = '0' else result_o;

-------------------------------------------------------

-- MEMORY MAP HANDLER ---------------------------------
--RAM: 0x2000 - 0x4000

    process(addr)
    begin
        if unsigned(addr) >= x"2000" and unsigned(addr) < x"4000" then
            mem_addr <= std_logic_vector(unsigned(addr) - x"2000");
            mem_en <= '1';
        else 
            mem_en <= '0';
            mem_addr <= (others => '0');
        end if;
    end process;

-------------------------------------------------------
    mem_we_o <= mem_we;
    mem_en_o <= mem_en;
    mem_addr_o <= mem_addr;
    mem_data_o <= mem_data;

    reg_pipeline : process(clk_i, rst_i)
    begin
        if rst_i = '1' then
            PC_IE <= (others => '0');
            result_o <= (others => '0');
            WB_start_o <= '0';
            rd_o <= (others => '0');
            br_update_o <= '0';
            jump_addr_o <= (others => '0');
        elsif rising_Edge(clk_i) then
            result_o <= result;
            WB_start_o <= WB_enb;
            rd_o <= rd_i;
            jump_addr_o <= jump_addr;
            br_update_o <= br_update;
            PC_IE <= PC_ID;
        end if;
    end process;
end RTL;
