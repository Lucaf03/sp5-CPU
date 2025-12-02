library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity instr_mem is
    generic (
        INSTR_MEM_DEPTH : integer := 1024;
        INSTR_MEM_FILE  : string  := "../build/hex/prog.hex"
    );
    port (
        clk  : in  std_logic;
        en   : in  std_logic;
        addr : in  std_logic_vector(31 downto 0);
        dout : out std_logic_vector(31 downto 0)
    );
end entity;

architecture sim of instr_mem is
    type mem_t is array (0 to INSTR_MEM_DEPTH-1) of std_logic_vector(31 downto 0);
    signal mem : mem_t := (others => (others => '0'));

    -- funzione per convertire carattere hex in valore
    function hex_val(c : character) return integer is
    begin
        case c is
            when '0' => return 0;
            when '1' => return 1;
            when '2' => return 2;
            when '3' => return 3;
            when '4' => return 4;
            when '5' => return 5;
            when '6' => return 6;
            when '7' => return 7;
            when '8' => return 8;
            when '9' => return 9;
            when 'a' | 'A' => return 10;
            when 'b' | 'B' => return 11;
            when 'c' | 'C' => return 12;
            when 'd' | 'D' => return 13;
            when 'e' | 'E' => return 14;
            when 'f' | 'F' => return 15;
            when others => return 0;
        end case;
    end function;
begin
    -- lettura asincrona
    process(addr, en, mem)
        variable waddr : integer;
    begin
        if en = '1' then
            waddr := to_integer(unsigned(addr(31 downto 2)));
            if waddr < INSTR_MEM_DEPTH then
                dout <= mem(waddr);
            else
                dout <= (others => '0');
            end if;
        else
            dout <= (others => '0');
        end if;
    end process;

    -- inizializzazione da file verilog-hex
    init_proc : process
        file f : text open read_mode is INSTR_MEM_FILE;
        variable l : line;
        variable s : string(1 to 512);
        variable len : integer;
        variable addr_bytes : integer := 0;
        variable byte_val   : integer;
        variable word       : std_logic_vector(31 downto 0);
        variable bidx       : integer := 0;
        variable waddr      : integer;
        variable i          : integer;
    begin
        while not endfile(f) loop
            readline(f, l);
            len := l'length;
            if len = 0 then
                next;
            end if;
            s(1 to len) := l.all;

            -- se la riga inizia con '@', aggiorna indirizzo
            if s(1) = '@' then
                addr_bytes := 0;
                for i in 2 to len loop
                    if s(i) /= ' ' then
                        addr_bytes := addr_bytes*16 + hex_val(s(i));
                    end if;
                end loop;
            else
                -- parsing byte per byte
                i := 1;
                while i < len loop
                    if s(i) = ' ' then
                        i := i + 1;
                    else
                        if i+1 <= len then
                            byte_val := hex_val(s(i))*16 + hex_val(s(i+1));
                            case bidx is
                                when 0 => word(7 downto 0)   := std_logic_vector(to_unsigned(byte_val,8));
                                when 1 => word(15 downto 8)  := std_logic_vector(to_unsigned(byte_val,8));
                                when 2 => word(23 downto 16) := std_logic_vector(to_unsigned(byte_val,8));
                                when 3 => word(31 downto 24) := std_logic_vector(to_unsigned(byte_val,8));
                                when others => null;
                            end case;
                            bidx := bidx + 1;
                            i := i + 2;
                            if bidx = 4 then
                                waddr := addr_bytes/4;
                                if waddr < INSTR_MEM_DEPTH then
                                    mem(waddr) <= word;
                                end if;
                                addr_bytes := addr_bytes + 4;
                                bidx := 0;
                                word := (others => '0');
                            end if;
                        else
                            i := i + 1;
                        end if;
                    end if;
                end loop;
            end if;
        end loop;
        wait;
    end process;
end architecture;
