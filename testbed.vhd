library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;

entity testbed is
end entity;

architecture testbed of testbed is

    type inputs_t is array(0 to 255) of signed(11 downto 0);
    
    constant inputs: inputs_t := (
        0 => x"000",
        1 => x"123",
        2 => x"456",
        3 => x"ABC",
        others => x"000"
    );
    
    signal cycle: natural             := 0;
    signal clk:   std_logic           := '1';
    signal input: signed(11 downto 0) := inputs(cycle);

begin
    input <= inputs(cycle mod 256);
    lmc: entity work.lmc port map(clk, '1', input);
    process is
    begin
    
        while TRUE loop
            clk <= '1';
            wait for 10 ns;
            clk <= '0';            
            wait for 10 ns;
            cycle <= cycle + 1;
        end loop;

    end process;
end architecture;
