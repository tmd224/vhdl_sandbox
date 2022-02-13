library ieee;
use ieee.std_logic_1164.all;
use std.env.finish;

entity interface_top_tb is 
end interface_top_tb;

architecture behavior of interface_top_tb is
    constant NUM_BITS: integer := 64;
    signal clk: std_logic := '0';
    signal i_le: std_logic := '1';
    signal data: std_logic_vector(NUM_BITS-1 downto 0) := X"7A11AA4411FFAACC"; --10000000";  --"00110101";
    signal i_data: std_logic := '0';
    signal o_data: std_logic_vector(NUM_BITS-1 downto 0);
    signal i: integer := NUM_BITS - 1;
    signal msb: std_logic_vector(7 downto 0);
    signal lsb: std_logic_vector(7 downto 0);

    begin
        dut: entity work.interface_top 
            port map (
                i_clk => clk,
                i_data => i_data,
                i_le => i_le,
                o_data => o_data,
                msb => msb,
                lsb => lsb
            );

        -- stimuli generator:
        clk <= not clk after 50 ns;
        
        process
        begin
            wait for 45ns;
            i_le <= '0';
            wait for 6395ns;
            i_le <= '1';
            wait for 100ns;
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


