library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity subtracao is
port(
    E0: in std_logic_vector(3 downto 0); -- Bonus Atual
    E1: in std_logic_vector(3 downto 0); -- Numero de Erros
    resultado: out std_logic_vector(3 downto 0)
);
end subtracao;

architecture arc of subtracao is
begin
    process(E0, E1)
    begin
        if E1 > E0 then
            resultado <= "0000"; -- Evita underflow (negativo)
        else
            resultado <= E0 - E1;
        end if;
    end process;
end arc;