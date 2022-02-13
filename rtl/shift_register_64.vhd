-- Serial-In Parallel Out Shift Register implementation

library ieee;
use ieee.std_logic_1164.all;

library work;


entity shift_register_64 is
    generic(
        NUM_BITS : integer := 64
    );
    port(
        i_clk: in std_logic;
        i_clear: in std_logic;
        i_le: in std_logic;
        i_data: in std_logic;
        o_data: out std_logic_vector(NUM_BITS-1 downto 0)
    );
end shift_register_64;

 architecture arch of shift_register_64 is
    constant RST_VAL : std_logic_vector(NUM_BITS-1 downto 0) := (others => '0');
    signal reg_out : std_logic_vector(NUM_BITS-1 downto 0) := RST_VAL;
    begin
        process (i_clk)
        begin
            if i_clear = '1' then
                reg_out <= RST_VAL;
            elsif rising_edge(i_clk) then
                if i_le = '0' then
                    -- only shift data in when latch en is low
                    reg_out(NUM_BITS-1 downto 1) <= reg_out(NUM_BITS-2 downto 0);
                    reg_out(0) <= i_data;
                end if;
            end if;
        end process;
        
        o_data <= reg_out;
        
        process (i_le)
        begin
            -- latch data into output register on the rising edge of latch en
            if rising_edge(i_le) then
                --o_data <= reg_out;
            end if;
        end process;
        
end arch;
