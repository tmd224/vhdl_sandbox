-- Simple Parallel DAC driver

library ieee;
use ieee.std_logic_1164.all;

entity parallel_dac is
    generic(
        constant BUS_WIDTH : integer := 10;      -- width of DAC data bus
        constant INIT_TIME_CLKS : integer := 100;  -- number of sys clks required in idle state to powerup/init part
        constant MIN_SETUP_CLKS : integer := 1;    -- setup time in sys clks
        constant MIN_HOLD_CLKS : integer := 1;     -- hold time in sys clks
        constant CS_CLK_CLKS : integer := 1       -- chip select tranisition to clock edge delay in sys clks
    );
    
    port(
        i_clk: in std_logic;
        i_rst: in std_logic;
        i_sample_clk: in std_logic;
        wr_en: in std_logic;
        i_data: in std_logic_vector(BUS_WIDTH-1 downto 0);        
        o_state: out std_logic_vector(1 downto 0)        
    );
end parallel_dac;

architecture rtl of parallel_dac is
    type state_t is (init, idle, write);
    signal state : state_t := init;
    signal init_count_en : boolean := FALSE ;
    signal cs_count_en : boolean := FALSE ;
    signal init_count_en : boolean := FALSE ;
    signal init_complete : boolean := FALSE;
    signal wr_complete : boolean := FALSE;
    
    begin
        process(i_clk, i_rst)
        -- state managment
        begin
            if i_rst = '1' then 
                state <= init;
                init_complete <= FALSE;
             elsif rising_edge(i_clk) then
                case state is 
                    when init =>
                        if init_complete = TRUE then
                            state <= idle; 
                        else
                            init_count_en <= TRUE;
                            state <= init;
                        end if;
                    when idle =>                                              
                      if wr_en = '1' then
                        state <= write;
                      else
                        state <= idle;
                      end if;
                    when write =>
                        if wr_complete = TRUE then
                            state <= idle;
                        else
                            state <= write;
                        end if;
                end case;
             end if;
         end process;
         
         -- state logic
         process (state)            
            begin
                case state is 
                    when init => 
                        o_state <= "00";                        
                    when idle => 
                        o_state <= "01";
                    when write =>
                        o_state <= "10";
                    end case;
         end process;
         
         -- init counter 
         process (i_clk)
            variable init_cnt : integer range 0 to INIT_TIME_CLKS := 0;
            begin
                -- count i_clk periods until we reach the end of the init period
                if init_count_en = TRUE then
                    if init_cnt >= INIT_TIME_CLKS then
                        init_complete <= TRUE;
                        init_cnt := 0;
                    else
                        init_cnt := init_cnt + 1;
                    end if;
                 end if;
         end process;
         
         process (i_clk, i_sample_clk)
            variable cs_cnt : integer range 0 to CS_CLK_CLKS :=0;
            variable setup_cnt : integer range 0 to MIN_SETUP_CLKS := 0;
            variable hold_cnt : integer range 0 to MIN_HOLD_CLKS := 0;
            begin
                if state = write then
                    -- write process entails deasserted the chip select, updating the data output, then asserting chip select
                    if rising_edge(i_sample_clk) then
                        -- wait for next sample clk edge first
                          
                    end if;
                 end if; 
         end process;
end rtl;