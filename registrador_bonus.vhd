library IEEE;
use IEEE.std_logic_1164.all;

entity registrador_bonus is 
port(
    S, E, clock: in std_logic; -- S ligado ao R2 (Reset Geral)
    D: in std_logic_vector(3 downto 0);
    Q: out std_logic_vector(3 downto 0) 
);
end registrador_bonus;

architecture arc of registrador_bonus is
begin
    process(clock, S)
    begin
        if S = '1' then
            Q <= "1111"; -- Reseta para 15 (Valor inicial do bônus)
        elsif rising_edge(clock) then
            if E = '1' then
                Q <= D; -- Carrega o valor de D em Q com E4
            end if;
        end if;
    end process;
end arc;