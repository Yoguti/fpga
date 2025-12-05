library IEEE;
use IEEE.std_logic_1164.all;

entity registrador_user is 
port(
    R, E, clock: in std_logic;
    D: in std_logic_vector(14 downto 0);
    Q: out std_logic_vector(14 downto 0) 
);
end registrador_user;

architecture arc of registrador_user is
begin
    process(clock, R)
    begin
        if R = '1' then -- R2
            Q <= (others => '0');
        elsif rising_edge(clock) then
            if E = '1' then
                Q <= D; -- Carrega o valor de D em Q com E3
            end if;
        end if;
    end process;
end arc;