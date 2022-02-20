library ieee;
use ieee.std_logic_1164.all;
use std.env.finish;


entity parallel_shift_tb is 
end parallel_shift_tb;

architecture sim of parallel_shift_tb is       
    constant NUM_BITS : integer := 24;
    constant SCLK_DIV : integer := 2;
    constant WORD1 : std_logic_vector(NUM_BITS-1 downto 0) := x"AFC4F1";
    constant WORD2 : std_logic_vector(NUM_BITS-1 downto 0) := x"F0AC41";
    
    -- timing constants for the simulation
    constant CLK_PERIOD : time := 39ns; 
    constant CLK_DELAY : time := CLK_PERIOD * 2;
    constant WR_EN_DELAY : time := CLK_PERIOD * 2 * SCLK_DIV * 4;
    constant FRAME_DELAY : time := CLK_PERIOD * 2 * SCLK_DIV * 16;
    -- DUT Inputs
    signal i_clk : std_logic := '0';
    signal i_rst : std_logic := '1';
    signal i_wr_en : std_logic := '0';
    signal data : std_logic_vector(NUM_BITS-1 downto 0);
    
    -- DUT outputs
    signal o_data : std_logic;
    signal o_state : std_logic_vector(1 downto 0);
    signal o_sclk : std_logic;
    signal o_cs_n : std_logic;
    signal o_busy : std_logic;
                    
begin
    dut: entity work.output_serial_interface
    generic map (
        NUM_BITS => NUM_BITS,
        SCLK_DIV => SCLK_DIV
    )
    
    port map (
        i_clk => i_clk,
        i_rst => i_rst,
        i_wr_en => i_wr_en,
        i_data => data,
        o_data => o_data,
        o_sclk => o_sclk,
        o_cs_n => o_cs_n,
        o_state => o_state,
        o_busy => o_busy
    );
    
    i_clk <= not i_clk after CLK_PERIOD;
    
    process
    begin
        wait for CLK_DELAY;
        i_rst <= '0';
        data <= WORD1;
        wait for CLK_DELAY;
        i_wr_en <= '1';
        wait for WR_EN_DELAY;
        i_wr_en <= '0';
        wait until o_busy = '0';
        data <= WORD1;
        wait for CLK_DELAY;
        i_wr_en <= '1';
        wait for WR_EN_DELAY;
        i_wr_en <= '0';
        wait until o_busy = '0';
        wait for CLK_DELAY*4;
        finish;
        wait;
        
    end process;
end sim;
