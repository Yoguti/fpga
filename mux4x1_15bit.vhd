LIBRARY IEEE;
USE IEEE.Std_Logic_1164.ALL;

ENTITY mux4x1_15bits IS
    PORT (
        E0, E1, E2, E3 : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
        sel : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        saida : OUT STD_LOGIC_VECTOR(14 DOWNTO 0)
    );
END mux4x1_15bits;

ARCHITECTURE circuito OF mux4x1_15bits IS
BEGIN
    saida <= E0 WHEN sel = "00" ELSE
             E1 WHEN sel = "01" ELSE
             E2 WHEN sel = "10" ELSE
             E3;
END circuito;