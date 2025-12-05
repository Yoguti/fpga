library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity counter_round is
port(
    R, E, clock: in std_logic;
    Q: out std_logic_vector(3 downto 0);
    tc: out std_logic
);
end counter_round;

architecture arc of counter_round is
    signal temp: std_logic_vector(3 downto 0);
begin
    process(clock, R)
    begin
        if R = '1' then -- R2
            temp <= "0000";
        elsif rising_edge(clock) then
            if E = '1' then -- E3
                temp <= temp + 1;
            end if;
        end if;
    end process;

    Q <= temp;
    tc <= '1' when temp = "1111" else '0'; -- Avisa quando chegou na última rodada (15/16) end_round
end arc;