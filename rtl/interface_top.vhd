

library ieee;
use ieee.std_logic_1164.all;

entity interface_top is     
    port (
        i_clk : in std_logic;
        i_data : in std_logic;
        i_le : in std_logic;
        o_data : out std_logic_vector (63 downto 0);
        msb: out std_logic_vector(7 downto 0) := X"00";
        lsb: out std_logic_vector(7 downto 0) := X"00"
    );

end interface_top;


architecture rtl of interface_top is
    constant SHIFT_REG_WIDTH: integer := 64;
    signal clr: std_logic := '0';
    signal reg_data: std_logic_vector(SHIFT_REG_WIDTH-1 downto 0) := (others=>'0');
    --signal msb: std_logic_vector(7 downto 0) := X"00";
    begin
        -- instantiate shift register 
        shift_reg : entity work.shift_register_64
            generic map (
                NUM_BITS => SHIFT_REG_WIDTH 
            )

            port map (
                i_clk => i_clk,
                i_clear => clr,
                i_le => i_le,
                i_data => i_data,
                o_data => reg_data
            );

        process (i_clk)
        begin
            if rising_edge (i_clk) then
                o_data <= reg_data;
            end if;
        end process;         
          
        process (i_le)
        begin
            if rising_edge(i_le) then
                msb <= reg_data(63 downto 56);
                if reg_data(63) = '1' then
                    lsb <= reg_data(7 downto 0);
                else
                    lsb <= X"FF";
                end if;
                    
            end if;
        end process;

end architecture;
