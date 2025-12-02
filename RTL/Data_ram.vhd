library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity data_ram is
    generic (
        DATA_MEM_DEPTH : integer := 1024
    );
    port (
        clk   : in  std_logic;
        rst : in std_logic;
        en    : in std_logic;
        we    : in  std_logic_vector(3 downto 0);
        addr  : in  std_logic_vector(31 downto 0);
        din   : in  std_logic_vector(31 downto 0);
        dout  : out std_logic_vector(31 downto 0)
    );
end entity;

architecture rtl of data_ram is
    type mem_t is array (0 to DATA_MEM_DEPTH-1) of std_logic_vector(31 downto 0);
    signal mem : mem_t;
begin

    -- Lettura asincrona
    dout <= mem(to_integer(unsigned(addr(31 downto 2)))) when en = '1' else (others => '0');

    -- Scrittura sincrona con byte enable
    process(clk, rst)
        variable waddr : integer;
        variable temp  : std_logic_vector(31 downto 0);
    begin
        if rst = '1' then
            for i in 0 to DATA_MEM_DEPTH-1 loop
                mem(i) <= (others => '0');
            end loop;
        elsif rising_edge(clk) then
            if en = '1' then
                waddr := to_integer(unsigned(addr(31 downto 2)));
                if waddr < DATA_MEM_DEPTH then
                    temp := mem(waddr);
                    if we(0) = '1' then temp(7 downto 0)   := din(7 downto 0);   end if;
                    if we(1) = '1' then temp(15 downto 8)  := din(15 downto 8);  end if;
                    if we(2) = '1' then temp(23 downto 16) := din(23 downto 16); end if;
                    if we(3) = '1' then temp(31 downto 24) := din(31 downto 24); end if;
                    mem(waddr) <= temp;
                end if;
            end if;
        end if;
    end process;

    -- Dump RAM a fine simulazione
    dump_proc : process
        file f : text open write_mode is "ram_dump.txt";
        variable l : line;
    begin
        wait for 1 ms;  -- cambiare con condizione di fine simulazione
        for i in 0 to DATA_MEM_DEPTH-1 loop
            hwrite(l, mem(i));
            writeline(f, l);
        end loop;
        wait;
    end process;

end rtl;
