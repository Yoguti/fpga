library IEEE;
use IEEE.std_logic_1164.all;

entity COMP_erro is
port(
    E0, E1: in std_logic_vector(14 downto 0);
    diferente: out std_logic_vector(14 downto 0)
);
end COMP_erro;

architecture arc of COMP_erro is
begin
    diferente <= E0 xor E1; -- XOR detecta diferenças
end arc;