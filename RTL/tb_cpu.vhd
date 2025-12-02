library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity tb_cpu is
end entity;

architecture sim of tb_cpu is
    ------------------------------------------------------------------
    -- Clock e reset
    ------------------------------------------------------------------
    signal clk_i       : std_logic := '0';
    signal rst_i       : std_logic := '1';
    signal global_en_i : std_logic := '0';

    ------------------------------------------------------------------
    -- Interfacce CPU <-> Memorie
    ------------------------------------------------------------------
    signal instr_mem_en    : std_logic := '0';
    signal instr_mem_addr  : std_logic_vector(31 downto 0) := (others => '0');
    signal instr_mem_data  : std_logic_vector(31 downto 0) := (others => '0');

    signal data_mem_en     : std_logic := '0';
    signal data_mem_we     : std_logic_vector(3 downto 0) := (others => '0');
    signal data_mem_addr   : std_logic_vector(31 downto 0) := (others => '0');
    signal mem_write_data  : std_logic_vector(31 downto 0) := (others => '0'); -- data from CPU to memory
    signal mem_read_data   : std_logic_vector(31 downto 0) := (others => '0'); -- data from memory to CPU

    ------------------------------------------------------------------
    -- Component declarations (assumendo siano in work)
    ------------------------------------------------------------------
    component CPU_top is
        port (
            --GLOBAL CPU I/O
            clk_i, rst_i, global_en_i : in std_logic;

            --INSTRUCTION MEMORY INTERFACE
            instr_mem_en_o   : out std_logic;
            instr_mem_addr_o : out std_logic_vector(31 downto 0);
            instr_mem_data_i : in  std_logic_vector(31 downto 0);

            --DATA MEMORY INTERFACE
            data_mem_en_o    : out std_logic;
            data_mem_we_o    : out std_logic_vector(3 downto 0);
            data_mem_data_i  : in  std_logic_vector(31 downto 0);
            data_mem_data_o  : out std_logic_vector(31 downto 0);
            data_mem_addr_o  : out std_logic_vector(31 downto 0)
        );
    end component;

    component instr_mem is
        generic (
            INSTR_MEM_DEPTH : integer := 1024;
            INSTR_MEM_FILE  : string  := "hex/prog.hex"
        );
        port (
            clk  : in  std_logic;
            en   : in  std_logic;
            addr : in  std_logic_vector(31 downto 0);
            dout : out std_logic_vector(31 downto 0)
        );
    end component;

    component data_ram is
        generic (
            DATA_MEM_DEPTH : integer := 1024
        );
        port (
            clk   : in  std_logic;
            rst   : in std_logic;
            en    : in  std_logic;
            we    : in  std_logic_vector(3 downto 0);
            addr  : in  std_logic_vector(31 downto 0);
            din   : in  std_logic_vector(31 downto 0);
            dout  : out std_logic_vector(31 downto 0)
        );
    end component;

begin

    ------------------------------------------------------------------
    -- CLOCK GENERATOR
    ------------------------------------------------------------------
    clk_proc : process
    begin
        while true loop
            clk_i <= '0';
            wait for 5 ns;
            clk_i <= '1';
            wait for 5 ns;
        end loop;
    end process;

    ------------------------------------------------------------------
    -- RESET GENERATOR (mantieni il reset qualche ciclo in più se serve)
    ------------------------------------------------------------------
    rst_proc : process
    begin
        rst_i <= '1';
        global_en_i <= '0';
        wait for 30 ns;         -- tieni reset un po' più a lungo per sicurezza
        rst_i <= '0';
        global_en_i <= '1';
        wait;
    end process;

    ------------------------------------------------------------------
    -- CPU UNDER TEST (senza memorie interne)
    ------------------------------------------------------------------
    cpu_inst : CPU_top
        port map (
            clk_i       => clk_i,
            rst_i       => rst_i,
            global_en_i => global_en_i,

            instr_mem_en_o   => instr_mem_en,
            instr_mem_addr_o => instr_mem_addr,
            instr_mem_data_i => instr_mem_data,

            data_mem_en_o    => data_mem_en,
            data_mem_we_o    => data_mem_we,
            data_mem_data_i  => mem_read_data,
            data_mem_data_o  => mem_write_data,
            data_mem_addr_o  => data_mem_addr
        );

    ------------------------------------------------------------------
    -- INSTRUCTION MEMORY (istanzia con file corretto)
    -- Nota: il generic INSTR_MEM_FILE è relativo alla working directory
    ------------------------------------------------------------------
    instr_mem_inst : instr_mem
        generic map (
            INSTR_MEM_DEPTH => 2048,
            INSTR_MEM_FILE  => "hex/prog.hex"   -- adattare se necessario
        )
        port map (
            clk  => clk_i,
            en   => instr_mem_en,
            addr => instr_mem_addr,
            dout => instr_mem_data
        );

    ------------------------------------------------------------------
    -- DATA MEMORY (istanzia con file corretto)
    ------------------------------------------------------------------
    data_mem_inst : data_ram
        generic map (
            DATA_MEM_DEPTH => 2048
        )
        port map (
            clk  => clk_i,
            rst  => rst_i,
            en   => data_mem_en,
            we   => data_mem_we,
            addr => data_mem_addr,
            din  => mem_write_data,
            dout => mem_read_data
        );



end architecture;
