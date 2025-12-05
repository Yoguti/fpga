library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ROM2a is
port(
      address: in std_logic_vector(3 downto 0);
      output : out std_logic_vector(14 downto 0)
);
end ROM2a;

architecture arc_ROM2a of ROM2a is
begin

--         switches 14 downto 0
output <= "000110101001011" when address = "0000" else
          "101001000111000" when address = "0001" else
          "010111000010110" when address = "0010" else
          "111000110100001" when address = "0011" else
          "001100111000101" when address = "0100" else
          "110010001010011" when address = "0101" else
          "011000100111100" when address = "0110" else
          "100101010001010" when address = "0111" else
          "000011110110001" when address = "1000" else
          "111101001000010" when address = "1001" else
          "001001011100111" when address = "1010" else
          "010010100001001" when address = "1011" else
          "101110000011000" when address = "1100" else
          "011101001110101" when address = "1101" else
          "110000111000100" when address = "1110" else
          "000100010101110";

end arc_ROM2a;