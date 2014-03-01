library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;

entity testbed is
end entity;

architecture testbed of testbed is

    type inputs_t is array(0 to 255) of signed(11 downto 0);

    signal cycle: natural := 0;
    signal clk: std_logic := '0';
    signal input: signed(11 downto 0);

    constant inputs: inputs_t := (
        0 => x"000",
        1 => x"123",
        2 => x"456",
        3 => x"ABC",
        others => x"000"
    );

begin
    input <= inputs(cycle);

    lmc: entity work.lmc port map(clk, '0', input);
    -- testbed
    process is
    begin

        input <= inputs(cycle mod 255);

        while TRUE loop
            clk <= '1';
            wait for 10 ns;
            clk <= '0';
            cycle <= cycle + 1;
            wait for 10 ns;
        end loop;

    end process;
end architecture;
