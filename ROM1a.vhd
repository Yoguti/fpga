library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ROM1a is
port(
      address: in std_logic_vector(3 downto 0);
      output : out std_logic_vector(14 downto 0)
);
end ROM1a;

architecture arc_ROM1a of ROM1a is
begin

--         switches 0 a 14
--         EDCBA9876543210                 round
output <= "010000000100100" when address = "0000" else
            "000010010010001" when address = "0001" else
             "001100100000001" when address = "0010" else
             "100000010100001" when address = "0011" else
             "000001100000110" when address = "0100" else
             "100000000000111" when address = "0101" else
             "001000000001011" when address = "0110" else
             "001010000001001" when address = "0111" else
             "000001001000101" when address = "1000" else
             "100000110000001" when address = "1001" else
             "000110000000011" when address = "1010" else
             "001100000001001" when address = "1011" else
             "010000100010001" when address = "1100" else
             "000000000100111" when address = "1101" else
             "110000010000001" when address = "1110" else
             "000100000011001";

end arc_ROM1a;