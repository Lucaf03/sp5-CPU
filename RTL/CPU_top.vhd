library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.sp_pkg.all;

entity CPU_top is
Port (
    --GLOBAL CPU I/O
    clk_i, rst_i, global_en_i : in std_logic;

    --INSTRUCTION MEMORY INTERFACE
    instr_mem_en_o : out std_logic;
    instr_mem_addr_o : out std_logic_vector(31 downto 0);
    instr_mem_data_i : in std_logic_vector(31 downto 0);

    --DATA MEMORY INTERFACE
    data_mem_en_o : out std_logic;
    data_mem_we_o : out std_logic_vector(3 downto 0);
    data_mem_data_i : in std_logic_vector(31 downto 0);
    data_mem_data_o : out std_logic_vector(31 downto 0);
    data_mem_addr_o : out std_logic_vector(31 downto 0)

);
end CPU_top;

architecture RTL of CPU_top is

    component Fetch_unit is
    Port ( 
        fetch_req_o : out std_logic;
        PC : in std_logic_vector(31 downto 0);
        PC_IF : out std_logic_vector(31 downto 0);
        pc_update_o : out std_logic;
        IF_start_i : in std_logic;
        clk_i, rst_i : in std_logic;
        lsu_busy : in std_logic;
        csr_busy : in std_logic;
        instr_i : in std_logic_vector(31 downto 0);
        stall_o : out std_logic;
        ID_start_o : out std_logic;
        instr_o : out std_logic_vector(31 downto 0)
    );
    end component;

    component Branch_Unit is 
    Port
    (
        clk_i, rst_i : in std_logic;
        instr_i : in std_logic_vector(31 downto 0);
        PC : in std_logic_vector(31 downto 0);
        br_update_i : in std_logic;
        br_addr_i : in std_logic_vector(31 downto 0);
        br_update_o : out std_logic;
        is_jal_o : out std_logic;
        IF_start_o : out std_logic;
        jump_addr_o: out std_logic_vector(31 downto 0)
    );
    end component;

    
    component Decode_Unit is
        Port ( 
            instr_i : in std_logic_vector(31 downto 0);
            ID_start_i : IN STD_logic;
            IE_start_o : out std_logic;
            PC_IF : in std_logic_vector(31 downto 0);
            PC_ID : out std_logic_vector(31 downto 0);
            clk_i, rst_i : in std_logic;
            stall_i : in std_logic;
            lsu_busy : out std_logic;
            instr_decoded_o : out INSTR_NAME;
            immediate_o : out std_logic_vector(31 downto 0);
            bypass1_o, bypass2_o : out std_logic;
            rs1_addr_o, rs2_addr_o, rd_addr_o : out std_logic_vector(4 downto 0);
            csr_busy_o : out std_logic;
            csr_addr_o : out std_logic_vector(11 downto 0)
        ); 
    end component;
    
    component Exec_Unit is
        Port ( 
            clk_i, rst_i, IE_start_i : in std_logic;
            op1_i, op2_i : in std_logic_vector(31 downto 0);
            immediate_i : in std_logic_vector(31 downto 0);
            rd_i : in std_logic_vector(4 downto 0);
            rd_o : out std_logic_vector(4 downto 0);
            --lsu_busy : out std_logic;
            rs1_addr_i, rs2_addr_i : in std_logic_vector(4 downto 0);
            instr_decoded_i : in INSTR_NAME;
            WB_enb_o : out std_logic;
            br_update_o : out std_logic;
            PC_ID : in std_logic_vector(31 downto 0);
            PC_IE : out std_logic_vector(31 downto 0);
            jump_addr_o : out std_logic_vector(31 downto 0);
            result_o : out std_logic_vector(31 downto 0);
            bypass1, bypass2 : in std_logic;
            csr_start_o : out std_logic; --Combinatorial signal
            csr_op_o : out std_logic_vector(31 downto 0); --Combinatorial signal
            csr_read_i : in std_logic_vector(31 downto 0);
            csr_op1_addr_o : out std_logic_vector(31 downto 0);
            --DATA MEMORY INTERFACE
            mem_en_o : out std_logic;
            mem_data_i : in std_logic_vector(31 downto 0);
            mem_data_o : out std_logic_vector(31 downto 0);
            mem_we_o : out std_logic_vector(3 downto 0);
            --mem_re_o : out std_logic;
            mem_addr_o : out std_logic_vector(31 downto 0)
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
            fetch_req_i : in std_logic;
            instr_mem_en_o : out std_logic;
            instr_addr_i : in std_logic_vector(31 downto 0)
         );
    end component;

    component CSR_unit is 
    Port(
        clk_i, rst_i : in std_logic;
        CSR_start : in std_logic;
        csr_addr_i : in std_logic_vector(11 downto 0);
        csr_rd_i : in std_logic_vector(4 downto 0);
        csr_op1_addr_i : in std_logic_vector(31 downto 0);
        csr_op_i : in std_logic_vector(31 downto 0);
        --csr_imm_i : in std_logic_vector(31 downto 0);
        instr_decoded_i : in INSTR_NAME;
        csr_rd_o : out std_logic_vector(4 downto 0);
        WB_start_o : out std_logic;
        csr_read_o : out std_logic_vector(31 downto 0)
    );
    end component;
    
-- There are probably some signals not used
    signal br_addr,instr_addr: std_logic_vector(31 downto 0);
    signal pc_update, br_update, fetch_en, if_start, if_start_br : std_logic;
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
    signal pc_wire3 : std_logic_vector(31 downto 0);
    signal bypass1, bypass2 : std_logic;
    --MUX
    signal jump_mux1, jump_mux2 : std_logic_vector(31 downto 0);
    signal is_jal : std_logic;
    signal br_update1, br_update2 : std_logic;
    signal instr_numb : INSTR_NAME;

    signal lsu_busy_wire, stall_wire1, stall_wire2, stall_or : std_logic;

    signal csr_start_wire : std_logic;
    signal csr_addr_wire : std_logic_vector(11 downto 0);
    signal csr_rd_wire : std_logic_vector(4 downto 0);
    signal csr_rs1_wire : std_logic_vector(4 downto 0);
    signal csr_op1_addr_wire : std_logic_vector(31 downto 0);
    signal csr_imm_wire : std_logic_vector(4 downto 0);
    signal csr_wr_wire : std_logic_vector(31 downto 0);
    signal csr_wb_enb_wire : std_logic;
    signal csr_busy_wire : std_logic;
    signal csr_op_wire : std_logic_vector(31 downto 0);

    signal rd_mux : std_logic_vector(4 downto 0);
    signal wr_mux : std_logic_vector(31 downto 0);
    signal wb_enb_mux : std_logic;
begin


    stall_or <= stall_wire1;
    instr_mem_addr_o <= instr_addr;

    rd_mux <= rd_towb when wb_enb_mux = '1' else csr_rd_wire;
    --wr_mux <= result when wb_enb_mux = '1' else csr_wr_wire;
    wb_enb_mux <= wr_en or csr_wb_enb_wire;

    PC_INST : pc_reg port map(
        clk_i => clk_i,
        rst_i => rst_i,
        instr_addr_i => br_addr,
        br_update_i => br_update,
        fetch_req_i => fetch_req,
        instr_mem_en_o => instr_mem_en_o,
        pc_update_i => pc_update,
        instr_addr_o => instr_addr
    );
    
    FETCH_INST : fetch_unit port map(
        clk_i => clk_i,
        rst_i => rst_i,
        IF_start_i => fetch_en,
        ID_start_o => decode_en,
        pc_update_o => pc_update,
        lsu_busy => lsu_busy_wire,
        csr_busy => csr_busy_wire,
        stall_o => stall_wire1,
        fetch_req_o => fetch_req,
        PC => instr_addr,
        PC_IF => pc_wire1,
        instr_i => instr_mem_data_i,
        instr_o => instr_fetched
    );

    BRANCH_INST: branch_unit port map(
        clk_i => clk_i,
        rst_i => rst_i,
        jump_addr_o => br_addr,
        br_update_o => br_update,
        is_jal_o => is_jal,
        PC => instr_addr,
        IF_start_o => if_start_br,
        br_update_i => br_update2,
        br_addr_i => jump_mux2,
        instr_i => instr_mem_data_i
    );

    DECODE_INST: decode_unit port map(
        clk_i => clk_i,
        rst_i => rst_i,
        instr_i => instr_fetched,
        PC_IF => pc_wire1,
        PC_ID => pc_wire2,
        ID_start_i => decode_en,
        IE_start_o => exec_en,
        stall_i => stall_or,
        rs1_addr_o => rs1_addr,
        rs2_addr_o => rs2_addr,
        lsu_busy => lsu_busy_wire,
        csr_busy_o => csr_busy_wire,
        rd_addr_o => rd_addr,
        immediate_o => imm,
        bypass1_o => bypass1,
        bypass2_o => bypass2,
        instr_decoded_o => instr_numb,
        csr_addr_o => csr_addr_wire
    );
    
    EX_INST : exec_unit port map(
        clk_i => clk_i,
        rst_i => rst_i,
        IE_start_i => exec_en,
        PC_ID => pc_wire2,
        PC_IE => pc_wire3,
        op1_i => op1,
        op2_i => op2,
        rd_i => rd_addr,
        rd_o => rd_towb,
        rs1_addr_i => rs1_addr,
        rs2_addr_i => rs2_addr,
        WB_enb_o => wr_en,
        bypass1 => bypass1,
        bypass2 => bypass2,
        --lsu_busy => lsu_busy_wire,
        immediate_i => imm,
        br_update_o => br_update2,
        jump_addr_o => jump_mux2,
        instr_decoded_i => instr_numb,
        result_o => result,
        CSR_start_o => csr_start_wire,
        csr_op_o => csr_op_wire,
        csr_read_i => csr_wr_wire,
        csr_op1_addr_o => csr_op1_addr_wire,
        mem_en_o => data_mem_en_o,
        mem_data_i => data_mem_data_i,
        mem_data_o => data_mem_data_o,
        mem_we_o => data_mem_we_o,
        mem_addr_o => data_mem_addr_o
    );
    
    RF_INST : register_file port map(
        clk_i => clk_i,
        rst_i => rst_i,
        rs1_addr_i => rs1_addr,
        rs2_addr_i => rs2_addr,
        op1_o => op1,
        op2_o => op2,
        wr_data_i => result,
        rd_i => rd_mux,
        wr_enb => wb_enb_mux
    );

    CSR_INST : CSR_unit port map(
        clk_i => clk_i, 
        rst_i => rst_i,
        CSR_start => csr_start_wire,
        csr_addr_i => csr_addr_wire,
        csr_rd_i => rd_addr,
        csr_op1_addr_i => csr_op1_addr_wire,
        csr_op_i => csr_op_wire,
        instr_decoded_i => instr_numb,
        csr_read_o => csr_wr_wire,
        WB_start_o => csr_wb_enb_wire,
        csr_rd_o => csr_rd_wire
    );
    fetch_en <= global_en_i and if_start_br;

end RTL;

