library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity button_press is
port(
    button : in std_logic;
    clk : in std_logic;
    pulse : out std_logic
);
end;

architecture synth of button_press is

signal count : std_logic_vector(1 DOWNTO 0);

begin
    process (clk, button) begin --process changes when clk or button changes
        if button = '1' then
            count <= "00";
            if (rising_edge(clk)) then

                 --if count is different from 11 keep adding
                if (count /= "11") then
                    count <= count + 1; 
                end if;

            end if;
            
            if (count = "10") and (key = '0') then
                pulse <= '1';
            else 
                pulse <= '0'; 
            end if;

        end if; 
    end process;

