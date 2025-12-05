library IEEE;
use IEEE.std_logic_1164.all;

entity registrador_sel is 
port(
    R, E, clock: in std_logic;
    D: in std_logic_vector(3 downto 0);
    Q: out std_logic_vector(3 downto 0) 
);
end registrador_sel;

architecture arc of registrador_sel is
begin
    process(clock, R)
    begin
        if R = '1' then -- R2
            Q <= "0000";
        elsif rising_edge(clock) then
            if E = '1' then
                Q <= D;
            end if;
        end if;
    end process;
end arc;