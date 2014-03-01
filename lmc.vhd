library ieee; 

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lmc is
    port(
        clk:         in  std_logic;
        rst:         in  std_logic;
        input:       in  signed(11 downto 0);
        output:      out signed(11 downto 0);
        input_warn:  out std_logic;
        output_warn: out std_logic;
        halt_warn:   out std_logic
    );
end entity;

architecture lmc of lmc is

    subtype word_t        is std_logic_vector(11 downto 0);
    subtype instruction_t is std_logic_vector(3 downto 0);
    
    type memory_t is array(255 downto 0) of word_t;
    
    signal ordinal_counter: natural := 0; -- index memory
    signal accumulator:     signed(11 downto 0);
    
    signal instruction_register: word_t;
    signal instruction:          instruction_t;
    signal address:              natural; -- index memory

    constant HLT: instruction_t := x"0"; -- halt (coffee break)
    constant ADD: instruction_t := x"1"; -- add 
    constant SUB: instruction_t := x"2";
    constant STA: instruction_t := x"3";
    constant NOP: instruction_t := x"4";
    constant LDA: instruction_t := x"5";
    constant BRA: instruction_t := x"6";
    constant BRZ: instruction_t := x"7";
    constant BRP: instruction_t := x"8";
    constant IO:  instruction_t := x"9"; -- 901 in, 902 out

    signal memory: memory_t := (
        0   => x"901",
        1   => x"1FF",
        2   => x"902",
        3   => x"901",
        4   => x"2FF",
        5   => x"902",
        6   => x"901",
        7   => x"3F0",
              
        8   => x"901",
        9   => x"400",
        10  => x"5F0",
        11  => x"902",
          
        12  => x"901",
        13  => x"70C",
        14  => x"5FE",
        15  => x"902",
        
        16  => x"901",
        17  => x"810",
        18  => x"5FD",
        19  => x"902",
        
        20  => x"600",		
            
        -- data
        253 => x"00A",
        254 => x"00B",
        255 => x"005",

        others	=> x"000"
   );

begin

    instruction_register <= memory(ordinal_counter);
    instruction          <= instruction_register(11 downto 8);
    address              <= to_integer(unsigned(instruction_register(7 downto 0)));
    
    -- output combinatory
    input_warn  <= '1' when instruction = IO and address = 1 else '0';
    output_warn <= '1' when instruction = IO and address = 2 else '0';
    halt_warn   <= '1' when instruction = HLT else '0';

    process (clk, rst) is
    begin

        if rst = '1' then
            ordinal_counter <= 0;
        elsif rising_edge(clk) then

            case instruction is
                when HLT => -- terminate the program (counter will not increase)
                    report "Program halted." severity NOTE;
                when ADD => 
                    accumulator <= accumulator + signed(memory(address));
                    ordinal_counter <= ordinal_counter + 1;
                when SUB => 
                    accumulator <= accumulator - signed(memory(address));
                    ordinal_counter <= ordinal_counter + 1;
                when LDA => 
                    accumulator <= signed(memory(address));
                    ordinal_counter <= ordinal_counter + 1;
                when NOP =>
                    ordinal_counter <= ordinal_counter + 1;
                when STA => 
                    memory(address) <= std_logic_vector(accumulator); 
                    ordinal_counter <= ordinal_counter + 1;
                when BRA => 
                    ordinal_counter <= address;             
                when BRZ =>
                    if accumulator = 0 then
                        ordinal_counter <= address;
                    else
                        ordinal_counter <= ordinal_counter + 1;
                    end if;
                when BRP =>
                    if accumulator >= 0 then
                        ordinal_counter <= address;
                    else
                        ordinal_counter <= ordinal_counter + 1;
                    end if;
                when IO  =>
                    case address is
                        when 1 => -- 901
                            accumulator <= input;
                        when 2 => -- 902
                            output <= accumulator;
                        when others =>
                            assert FALSE report "Illegal i/o instruction." severity ERROR;
                    end case;
                    ordinal_counter <= ordinal_counter + 1;
                when others =>
                    assert FALSE report "Illegal instruction." severity ERROR;
            end case;
        end if;
    end process;
end architecture;
