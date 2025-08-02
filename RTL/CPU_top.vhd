library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity CPU_top is
Port (
    --GLOBAL CPU I/O
    clk_i, rst_i, global_en_i : in std_logic;

    --INSTRUCTION MEMORY INTERFACE
    instr_mem_rd_o : out std_logic;                         --Instruction memory read enable
    instr_mem_addr_o : out std_logic_vector(9 downto 0);    --Instrunction memory address
    instr_mem_data_i : in std_logic_vector(31 downto 0);    --Instruction memory data output

    --DATA MEMORY INTERFACE
    data_mem_we_o : out std_logic_vector(3 downto 0);       --Data memory write enable
    data_mem_addr_o : out std_logic_vector(12 downto 0);    --Data memory address
    data_mem_data_o : out std_logic_vector(31 downto 0);    --Data memory data input
    data_mem_data_i : in std_logic_vector(31 downto 0)      --Data memory data output
);
end CPU_top;

architecture RTL of CPU_top is
    component Fetch_unit is
        Port ( 
            fetch_req_o : out std_logic;
            present_pc_i : in std_logic_vector(31 downto 0);
            present_pc_o : out std_logic_vector(31 downto 0);
            pc_update_o, br_update_o : out std_logic;
            IF_start_i : in std_logic;
            clk_i, rst_i : in std_logic;
            instr_i : in std_logic_vector(31 downto 0);
            ID_start_o, is_jal_o : out std_logic;
            instr_o, jump_addr_o : out std_logic_vector(31 downto 0)
        );
    end component;
    
    component Decode_Unit is
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
    end component;
    
    component Exec_Unit is
        Port ( 
            clk_i, rst_i, IE_start_i : in std_logic;
            op1_i, op2_i : in std_logic_vector(31 downto 0);
            immediate_i : in std_logic_vector(31 downto 0);
            rd_i : in std_logic_vector(4 downto 0);
            rd_o : out std_logic_vector(4 downto 0);
            rs1_addr_i, rs2_addr_i : in std_logic_vector(4 downto 0);
            instr_numb_i : in std_logic_vector(5 downto 0);
            WB_start_o : out std_logic;
            br_update_o : out std_logic;
            present_pc_i : in std_logic_vector(31 downto 0);
            jump_addr_o : out std_logic_vector(31 downto 0);
            result_o : out std_logic_vector(31 downto 0);
            --DATA MEMORY INTERFACE
            mem_data_i : in std_logic_vector(31 downto 0);
            mem_data_o : out std_logic_vector(31 downto 0);
            mem_we_o : out std_logic_vector(3 downto 0);
            --mem_re_o : out std_logic;
            mem_addr_o : out std_logic_vector(31 downto 0)
        );
    end component;
    
    component WriteBack_Unit is
        Port (
            clk_i, rst_i : in std_logic;
            data_i : in std_logic_vector(31 downto 0);
            data_o : out std_logic_vector(31 downto 0);
            wr_rf_o : out std_logic; 
            IF_start_o : out std_logic;
            WB_start_i : in std_logic
         );
    end component;
    
    component Register_file is
        Port (
            rs1_addr_i, rs2_addr_i : in std_logic_vector(4 downto 0);
            op1_o, op2_o : out std_logic_vector(31 downto 0);
            wr_data_i : in std_logic_vector(31 downto 0);
            wr_enb : in std_logic;
            clk_i, rst_i : in std_logic;
            rd_i : in std_logic_vector(4 downto 0)
         );
    end component;
    
    component PC_reg is
        Port (
            instr_addr_o : out std_logic_vector(31 downto 0);
            pc_update_i, br_update_i : in std_logic;
            clk_i, rst_i : in std_logic;
            instr_addr_i : in std_logic_vector(31 downto 0)
         );
    end component;

--    component blk_mem_gen_0 IS
--      PORT (
--        clka : IN STD_LOGIC;
--        rsta : IN STD_LOGIC;
--        ena : IN STD_LOGIC;
--        addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
--        douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
--      );
--    END component;

--    component blk_mem_gen_1 IS
--    PORT (
--        clka : IN STD_LOGIC;
--        rsta : IN STD_LOGIC;
--        wea : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
--        addra : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
--        dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
--        douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
--        rsta_busy : OUT STD_LOGIC
--    );
--    END component;
    
-- There are probably some signals not used
    signal br_addr,instr_addr32: std_logic_vector(31 downto 0);
    signal instr_addr : std_logic_vector(9 downto 0);
    signal pc_update, br_update, fetch_en : std_logic;
    signal fetch_req, instr_mem_rd : std_logic;
    signal instr, instr_fetched : std_logic_vector(31 downto 0);
    signal decode_en : std_logic;
    signal rs1_addr, rs2_addr, rd_addr, rd_towb : std_logic_vector(4 downto 0);
    signal exec_en : std_logic;
    signal op1, op2 : std_logic_vector(31 downto 0);
    signal imm : std_logic_vector(31 downto 0);
    signal result : std_logic_vector(31 downto 0);
    signal wb_en, wr_en : std_logic;
    signal wr_data : std_logic_vector(31 downto 0);
    signal pc_wire1, pc_wire2 : std_logic_vector(31 downto 0);
    --MUX
    signal jump_mux1, jump_mux2 : std_logic_vector(31 downto 0);
    signal is_jal : std_logic;
    signal br_update1, br_update2 : std_logic;
    signal instr_numb : std_logic_vector(5 downto 0);

    --DATA MEM
    signal rsta_busy : std_logic;
    signal mem_write : std_logic_vector(3 downto 0);
    signal mem_input : std_logic_vector(31 downto 0);
    signal mem_output : std_logic_vector(31 downto 0);
    signal mem_data : std_logic_vector(31 downto 0);
    signal mem_addr : std_logic_vector(31 downto 0);
    signal mem_addr13 : std_logic_vector(12 downto 0);
begin
    instr_mem_rd_o <= instr_mem_rd;
    instr_mem_addr_o <= instr_addr;
    instr_mem_data_i <= instr;
    data_mem_we_o <= mem_write;
    data_mem_addr_o <= mem_addr13;
    data_mem_data_o <= mem_data;
    data_mem_data_i <= mem_output;

    instr_addr <= instr_addr32(11 downto 2);
    --MUXES
    br_addr <= jump_mux1 when is_jal = '1' else jump_mux2;
    br_update <= br_update1 when is_jal = '1' else br_update2;

    mem_addr13 <= mem_addr(12 downto 0);
    
    PC_INST : pc_reg port map(
        clk_i => clk_i,
        rst_i => rst_i,
        instr_addr_i => br_addr,
        br_update_i => br_update,
        pc_update_i => pc_update,
        instr_addr_o => instr_addr32
    );
    
--    INSTR_INST : blk_mem_gen_0 port map(
--            clka => clk_i,
--            rsta => rst_i,
--            ena => instr_mem_rd,
--            addra => instr_addr,
--            douta => instr
--    );
    
    FETCH_INST : fetch_unit port map(
        clk_i => clk_i,
        rst_i => rst_i,
        IF_start_i => fetch_en,
        ID_start_o => decode_en,
        jump_addr_o => jump_mux1,
        br_update_o => br_update1,
        pc_update_o => pc_update,
        is_jal_o => is_jal,
        fetch_req_o => instr_mem_rd,
        present_pc_i => instr_addr32,
        present_pc_o => pc_wire1,
        instr_i => instr,
        instr_o => instr_fetched
    );
    
    DECODE_INST: decode_unit port map(
        clk_i => clk_i,
        rst_i => rst_i,
        instr_i => instr_fetched,
        present_pc_i => pc_wire1,
        present_pc_o => pc_wire2,
        ID_start_i => decode_en,
        IE_start_o => exec_en,
        rs1_addr_o => rs1_addr,
        rs2_addr_o => rs2_addr,
        rd_addr_o => rd_addr,
        immediate_o => imm,
        instr_numb_o => instr_numb
    );
    
    EX_INST : exec_unit port map(
        clk_i => clk_i,
        rst_i => rst_i,
        IE_start_i => exec_en,
        present_pc_i => pc_wire2,
        op1_i => op1,
        op2_i => op2,
        rd_i => rd_addr,
        rd_o => rd_towb,
        rs1_addr_i => rs1_addr,
        rs2_addr_i => rs2_addr,
        WB_start_o => wb_en,
        immediate_i => imm,
        br_update_o => br_update2,
        jump_addr_o => jump_mux2,
        instr_numb_i => instr_numb,
        result_o => result,
        mem_data_i => mem_output,
        mem_data_o => mem_data,
        mem_we_o => mem_write,
        --mem_re_o => mem_read,
        mem_addr_o => mem_addr
    );
    
--    DATA_INST : blk_mem_gen_1 port map(
--        clka => clk_i,
--        rsta => rst_i,
--        wea => mem_write,
--        addra => mem_addr13,
--        dina => mem_data,
--        douta => mem_output,
--        rsta_busy => rsta_busy
--    );

    WB_INST : writeback_unit port map(
        clk_i => clk_i,
        rst_i => rst_i,
        data_i => result,
        data_o => wr_data,
        IF_start_o => fetch_req,
        wr_rf_o => wr_en,
        WB_start_i => wb_en
    );
    
    RF_INST : register_file port map(
        clk_i => clk_i,
        rst_i => rst_i,
        rs1_addr_i => rs1_addr,
        rs2_addr_i => rs2_addr,
        op1_o => op1,
        op2_o => op2,
        wr_data_i => wr_data,
        rd_i => rd_towb,
        wr_enb => wr_en
    );
    fetch_en <= fetch_req or global_en_i;
end RTL;
