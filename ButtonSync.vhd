library ieee;
use ieee.std_logic_1164.all;

entity ButtonSync is
    port (
        KEY1, KEY0 : in  std_logic;
        CLK        : in  std_logic;
        BTN1, BTN0 : out std_logic
    );
end ButtonSync;

architecture rtl of ButtonSync is
    signal k1_s0, k1_s1, k0_s0, k0_s1 : std_logic := '1';
begin
    process(CLK)
    begin
        if rising_edge(CLK) then
            -- two-stage synchronizer for KEY1
            k1_s0 <= KEY1;
            k1_s1 <= k1_s0;
            -- two-stage synchronizer for KEY0
            k0_s0 <= KEY0;
            k0_s1 <= k0_s0;
        end if;
    end process;

    -- outputs active-high while key pressed (KEY is active-low)
    BTN1 <= not k1_s1;
    BTN0 <= not k0_s1;
end rtl;
