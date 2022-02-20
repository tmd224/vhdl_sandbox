-- Input syncronous serial interface with sync pulse

library ieee;
use ieee.std_logic_1164.all;

entity serial_shift_sync is
    generic(
        BIT_WIDTH : integer := 16
    );
    port (
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_sclk : in std_logic;
        i_data : in std_logic;
        i_strobe : in std_logic;
        o_data_reg : out std_logic_vector(BIT_WIDTH-1 downto 0);
        o_data_valid : out std_logic 
   );
end serial_shift_sync;

architecture rtl of serial_shift_sync is
    constant RST_VAL : std_logic_vector(BIT_WIDTH-1 downto 0) := (others => '0');
    signal reg_out : std_logic_vector(BIT_WIDTH-1 downto 0) := RST_VAL;
    signal bit_cnt : integer range 0 to BIT_WIDTH := 0;
    signal data_valid : std_logic := '0';
    
begin
    process(i_clk, i_sclk, i_strobe)
    begin
        if rising_edge(i_clk) then
            if i_rst = '1' then
                reg_out <= RST_VAL;
                o_data_reg <= reg_out;
                o_data_valid <= '0';
                bit_cnt <= 0;
            end if;
        end if;
        if falling_edge(i_sclk) then
            reg_out(BIT_WIDTH-1 downto 1) <= reg_out(BIT_WIDTH-2 downto 0);
            reg_out(0) <= i_data;
            bit_cnt <= bit_cnt + 1;                        
        end if;
        
        if falling_edge(i_strobe) then
            o_data_reg <= reg_out;
            data_valid <= '1';
            o_data_valid <= data_valid;
            bit_cnt <= 0;
        end if;
        
        if rising_edge(i_strobe) then
            if data_valid = '1' then
                data_valid <= '0';
                o_data_valid <= data_valid;
            end if;
        end if;
    
    end process;


end rtl;