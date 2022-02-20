library ieee;
use ieee.std_logic_1164.all;

-- This is a generic parallel in, serial out shift register architecture
-- Outputs a serial clk, data line, and active low chip select
-- This design is only capable of running with SCLK = i_CLK / 2 or lower (SCLK = i_clk invalid)

entity output_serial_interface is
    
    generic(
        NUM_BITS : integer := 24;       -- i_data bit width
        SCLK_DIV : integer := 2         -- o_sclk = i_clk / SCLK_DIV
    );
    
    port (
        i_clk  : in std_logic;
        i_rst  : in std_logic;
        i_data : in std_logic_vector(NUM_BITS-1 downto 0);
        i_wr_en: in std_logic;
        o_data : out std_logic := '0';
        o_sclk : out std_logic := '0';
        o_cs_n : out std_logic := '1';
        o_state: out std_logic_vector(1 downto 0) := "00";
        o_busy : out std_logic := '0'
    );
    
end output_serial_interface;

architecture rtl of output_serial_interface is
    constant NUM_CLKS : integer := NUM_BITS * SCLK_DIV;     --number of sclk edges to product
    type state_t is (init, idle, write);
    signal state : state_t := init;
    signal sclk : std_logic := '0';
    signal sclk_en : boolean := FALSE;
    signal wr_complete : boolean := FALSE;
    
    signal bit_cnt : integer range 0 to NUM_BITS := 0;
    signal clk_edge_cnt : integer range 0 to NUM_BITS := 0;

begin
    -- state machine control
    SM : process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_rst = '1' then 
                state <= init;
                o_cs_n <= '1';
                sclk_en <= FALSE;      
                o_state <= "00";    
                o_busy <= '0';      
            else
                case state is
                    when init =>
                        o_state <= "00";
                        state <= idle;   -- pass through state for now     
                        o_busy <= '0';                     
                    when idle => 
                        o_state <= "01";
                        o_busy <= '0';  
                        if i_wr_en = '1' then
                            state <= write;      
                        else
                            sclk_en <= FALSE;
                            o_cs_n <= '1';                                                  
                        end if;
                    when write =>
                        o_busy <= '1';
                        if wr_complete = FALSE then
                            o_state <= "10";
                            sclk_en <= TRUE;
                            o_cs_n <= '0';  
                        else
                            sclk_en <= FALSE;
                            o_cs_n <= '1';
                            state <= idle;
                        end if;
                end case;
            end if;
       end if; 
    end process;
    
    sclk_gen : process(i_clk) is
    -- process to generate the sclk when we are in write state
    variable cnt : integer range 0 to SCLK_DIV := 0;
    --variable clk_edge_cnt : integer range 0 to NUM_BITS := 0;
    begin
        if rising_edge(i_clk) then
            if i_rst = '1' then
                cnt := 0;
                sclk <= '0';
            elsif sclk_en = TRUE then
                if clk_edge_cnt < NUM_CLKS then
                    cnt := cnt + 1;
                    if cnt = (SCLK_DIV - 1) then 
                        sclk <= not sclk;
                        cnt := 0;
                        clk_edge_cnt <= clk_edge_cnt + 1;
                    end if;
                 end if;
            else
                sclk <= '0';
                cnt := 0;
                clk_edge_cnt <= 0;
            end if;
        end if;
        o_sclk <= sclk;
    end process;    
    
    write_data : process(i_clk, sclk) is
    constant MSB : integer := NUM_BITS - 1;
    --variable bit_cnt : integer range 0 to NUM_BITS := 0;
    begin
    
        if rising_edge(i_clk) then
            if i_rst = '1' then
                bit_cnt <= 0;
                o_data <= '0';
            end if;
            if i_wr_en = '1' then
                wr_complete <= FALSE;
                if bit_cnt = 0 then
                    o_data <= i_data(MSB);  -- setup first bit early
                    bit_cnt <= 1;
                end if;
            else            
                if bit_cnt > NUM_BITS then
                    wr_complete <= TRUE;   
                    o_data <= '0';  
                    bit_cnt <= 0;
                    --bit_cnt <= 1;  
                end if;
             end if;
        end if;
        
        -- shift data bit out on sclk edge MSB first
        if falling_edge(sclk) then
            if wr_complete = FALSE then
                if bit_cnt <= MSB then
                    o_data <= i_data(MSB-bit_cnt);    --(bit_cnt+1) since we already setup the first bit above                    
                end if;
                bit_cnt <= bit_cnt + 1;
            end if;
        end if;
    end process;
    
    
    
    
end rtl;