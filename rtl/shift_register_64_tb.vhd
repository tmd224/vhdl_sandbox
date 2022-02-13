library ieee;
use ieee.std_logic_1164.all;
use std.env.finish;

entity shift_register_64_tb is 
end shift_register_64_tb;

architecture behavior of shift_register_64_tb is
    constant NUM_BITS: integer := 64;
    signal clk: std_logic := '0';
    signal clr: std_logic := '0';
    signal i_le: std_logic := '1';
    signal data: std_logic_vector(NUM_BITS-1 downto 0) := X"FA00AA4411FFAA00"; --10000000";  --"00110101";
    signal i_data: std_logic := '0';
    signal o_data: std_logic_vector(NUM_BITS-1 downto 0);
    signal i: integer := NUM_BITS - 1;

    begin
        dut: entity work.shift_register_64 
        port map (clk, clr, i_le, i_data, o_data);

        -- stimuli generator:
        clk <= not clk after 50 ns;
        
        process
        begin
            wait for 10ns;
            clr <= '1'; 
            wait for 30ns;
            clr <= '0'; 
            wait for 5ns;
            i_le <= '0';
            wait for 6395ns;
            i_le <= '1';
            wait for 10ns;
            finish;
            wait;
        end process;
        
        process(clk)
        begin
            -- shift out MSB first
            i_data <= data(i);
            if rising_edge(clk) then
                if i > 0 then
                    i <= i - 1;
                end if;
            end if;
        end process;
end behavior;


