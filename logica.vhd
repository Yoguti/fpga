library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all; -- soma de vet

entity logica is 
port(
    round, bonus: in std_logic_vector(3 downto 0);
    nivel: in std_logic_vector(1 downto 0);
    points: out std_logic_vector(7 downto 0)
);
end logica;

architecture arc of logica is
    signal parcela_nivel : std_logic_vector(7 downto 0);
    signal parcela_bonus : std_logic_vector(7 downto 0);
    signal parcela_round : std_logic_vector(7 downto 0);
begin

    -- 32 * Nivel concatenar "00000"
    -- Nivel (2 bits) + 5 zeros = 7 bits + '0' pra 8 bits
    parcela_nivel <= '0' & nivel & "00000";

    -- 4 * (Bonus / 2)
    -- Bonus / 2: descartar o bit 0, só o bonus(3 downto 1)
    -- Multiplicar o resultado por 4: "00" no final
    parcela_bonus <= "000" & bonus(3 downto 1) & "00";

    -- Round / 4
    -- Dividir por 4 descartar os dois bits finais
    -- round(3 downto 2) e enchemos de zero na frente.
    parcela_round <= "000000" & round(3 downto 2);

    -- Soma Final
    points <= parcela_nivel + parcela_bonus + parcela_round;

end arc;