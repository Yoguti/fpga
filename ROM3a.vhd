library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ROM3a is
port(
      address: in std_logic_vector(3 downto 0);
      output : out std_logic_vector(14 downto 0)
);
end ROM3a;

architecture arc_ROM3a of ROM3a is
begin

--         switches 14 downto 0
output <= "111000010010111" when address = "0000" else
          "000111100100000" when address = "0001" else
          "101010100001001" when address = "0010" else
          "010001011110010" when address = "0011" else
          "100110000011100" when address = "0100" else
          "001011101001010" when address = "0101" else
          "110100010100001" when address = "0110" else
          "011001001010111" when address = "0111" else
          "000101111000011" when address = "1000" else
          "101100001111000" when address = "1001" else
          "010010000101101" when address = "1010" else
          "111011010000110" when address = "1011" else
          "001110111100001" when address = "1100" else
          "100001001011010" when address = "1101" else
          "011111000010100" when address = "1110" else
          "000011010111001";

end arc_ROM3a;