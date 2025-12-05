LIBRARY IEEE;
USE IEEE.Std_Logic_1164.ALL;

ENTITY mux2x1_7bits IS
    PORT (
        E0, E1 : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
        sel : IN STD_LOGIC;
        saida : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
    );
END mux2x1_7bits;

ARCHITECTURE circuito OF mux2x1_7bits IS
BEGIN
    saida <= E0 WHEN sel = '0' ELSE E1;
END circuito;