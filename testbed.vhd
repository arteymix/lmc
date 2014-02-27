library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;

entity testbed is
    port(
        rst:         in  std_logic;
        input:       in  signed(11 downto 0);
        output:      out signed(11 downto 0);
        input_warn:  out std_logic;
        output_warn: out std_logic;
        halt_warn:   out std_logic
    );
end entity;

architecture testbed of testbed is
    signal clk: std_logic := '0';
begin
    lmc: entity work.lmc port map(clk, rst, input, output, input_warn, output_warn, halt_warn);
    -- testbed
    process is
    begin
        while TRUE loop
            clk <= '1';
            wait for 500 ms;
            clk <= '0';
            wait for 500 ms;
        end loop;
    end process;
end architecture;
