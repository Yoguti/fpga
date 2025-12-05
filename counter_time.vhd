library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity counter_time is 
port(
    R, E, clock: in std_logic;
    Q: out std_logic_vector(3 downto 0);
    tc: out std_logic
);
end counter_time;

architecture arc of counter_time is
    signal temp: std_logic_vector(3 downto 0);
begin
    process(clock, R)
    begin
        if R = '1' then -- R1
            temp <= "1010"; -- Começa em 10 segundos
        elsif rising_edge(clock) then
            if E = '1' then -- E3
                if temp > 0 then
                    temp <= temp - 1;
                end if;
            end if;
        end if;
    end process;

    Q <= temp;
    tc <= '1' when temp = "0000" else '0'; -- Avisa quando acabou o tempo end_time
end arc;