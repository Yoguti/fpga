library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all; -- soma
entity bit_sum is
    port (
        entrada : in  std_logic_vector(14 downto 0);
        soma    : out std_logic_vector(3 downto 0)
    );
end bit_sum;

architecture behavior of bit_sum is
begin
    process(entrada)
        variable count : integer range 0 to 15;
    begin
        count := 0;
        for i in 0 to 14 loop
            if entrada(i) = '1' then
                count := count + 1;
            end if;
        end loop;
        soma <= std_logic_vector(to_unsigned(count, 4));
    end process;
end behavior;