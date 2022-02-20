library ieee;
use ieee.std_logic_1164.all;
use std.env.finish;


entity serial_shift_sync_tb is 
end serial_shift_sync_tb;

architecture sim of serial_shift_sync_tb is
    constant BIT_WIDTH: integer := 8;
    constant SCLK_DIV : integer := 2;
    
    signal clk : std_logic := '0';
    signal rst : std_logic := '1';
    signal sclk : std_logic := '0';
    signal strobe : std_logic := '0';
    signal i_data : std_logic := '0';
    --signal WORD1 : std_logic_vector(BIT_WIDTH-1 downto 0) := x"AC";
    --signal WORD2 : std_logic_vector(BIT_WIDTH-1 downto 0) := x"F2";
    --signal next_word : std_logic_vector(BIT_WIDTH-1 downto 0) := x"00";
    signal data_out : std_logic_vector(BIT_WIDTH-1 downto 0);
    signal data_ready : std_logic;
    
    
    subtype t_data_word is std_logic_vector(BIT_WIDTH-1 downto 0);
    type t_vector is array (0 to 4) of t_data_word;
    constant data_array : t_vector := (x"AC", x"F2", x"AA", x"84", x"CF");
    signal data_ptr : integer := 0;
    
    --sim constants/signals
    constant HALF_CLK_PER : time := 39ns;
    signal clk_cnt : integer range 0 to SCLK_DIV-1 := 0;
       
begin
    dut: entity work.serial_shift_sync
    generic map (
        BIT_WIDTH => BIT_WIDTH
    )
    port map (
        i_clk => clk,
        i_sclk => sclk,
        i_rst => rst,
        i_strobe => strobe,
        i_data => i_data,
        o_data_reg => data_out,
        o_data_valid => data_ready
    );
    
    clk <= not clk after HALF_CLK_PER;
    sclk <= not sclk after HALF_CLK_PER * SCLK_DIV;
    
    -- main sim process
    process
    begin
        wait for HALF_CLK_PER * 4;
        rst <= '0';
        --next_word <= WORD1;
        --wait for HALF_CLK_PER * SCLK_DIV * 2 * BIT_WIDTH + (HALF_CLK_PER * 4);
        wait for 10000ns;
        finish;
        wait;
    end process;
    
    -- generate sclk
--    process(clk)
--    begin
--        if rising_edge(clk) then
--            if rst = '0' then
--                clk_cnt <= clk_cnt + 1;
--                if clk_cnt = SCLK_DIV - 1 then
--                    sclk <= not sclk;
--                    clk_cnt <= 0;
--                end if;
--            end if;
--        end if;    
--    end process;
    
    -- shift data out on sclk rising edge (DUT latches data on falling edge)
    process (sclk)
        constant MSB : integer := BIT_WIDTH - 1;
        variable bit_idx : integer range 0 to BIT_WIDTH + 1 := 0;
      
    begin
        if rising_edge(sclk) then
            if rst = '0' then 
                -- setup data on rising edge
                if bit_idx <= BIT_WIDTH -1 then
                    i_data <= data_array(data_ptr)(MSB-bit_idx);
                end if;
                bit_idx := bit_idx + 1;
                if bit_idx = BIT_WIDTH then
                    --bit_idx := 0;
                    strobe <= '1';                   
                end if;
                if bit_idx = BIT_WIDTH + 1 then                
                    bit_idx := 0;
                    strobe <= '0';
                    data_ptr <= data_ptr + 1;
                end if;
            end if;
        end if;
    end process;
    
end sim;