LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY topo IS
    PORT (
        CLOCK_50 : IN STD_LOGIC;
        CLK_500Hz : IN STD_LOGIC;
        KEY : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        SW : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
        HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        LEDR : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END topo;

ARCHITECTURE circuito OF topo IS
    SIGNAL enter, reset : STD_LOGIC;
    SIGNAL R1, R2, E1, E2, E3, E4, E5 : STD_LOGIC;
    SIGNAL end_game, end_time, end_round, end_FPGA : STD_LOGIC;

    COMPONENT datapath IS
        PORT (
            -- Entradas de dados
            clk : IN STD_LOGIC;
            SW : IN STD_LOGIC_VECTOR(17 DOWNTO 0);

            -- Entradas de controle
            R1, R2, E1, E2, E3, E4, E5 : IN STD_LOGIC;

            -- Saídas de dados
            hex0, hex1, hex2, hex3, hex4, hex5, hex6, hex7 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
            ledr : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);

            -- Saídas de status
            end_game, end_time, end_round, end_FPGA : OUT STD_LOGIC
        );
    END COMPONENT;

    COMPONENT controle IS
        PORT (
            -- Entradas de controle
            enter, reset, CLOCK : IN STD_LOGIC;
            -- Entradas de status
            end_game, end_time, end_round, end_FPGA : IN STD_LOGIC;
            -- Saídas de comandos
            R1, R2, E1, E2, E3, E4, E5 : OUT STD_LOGIC
        );
    END COMPONENT;

    COMPONENT ButtonSync IS PORT (--saida ja negada

        KEY1, KEY0, CLK : IN STD_LOGIC;
        BTN1, BTN0 : OUT STD_LOGIC);

    END COMPONENT;

BEGIN
    -- sincroniza botões (KEY1 -> enter, KEY0 -> reset)
    BS_inst : ButtonSync
    PORT MAP(
        KEY1 => KEY(1),
        KEY0 => KEY(0),
        CLK => CLOCK_50,
        BTN1 => enter,
        BTN0 => reset
    );

    -- datapath (associação por nome)
    DP_inst : datapath
    PORT MAP(
        clk => CLOCK_50,
        SW => SW,
        R1 => R1,
        R2 => R2,
        E1 => E1,
        E2 => E2,
        E3 => E3,
        E4 => E4,
        E5 => E5,
        hex0 => HEX0,
        hex1 => HEX1,
        hex2 => HEX2,
        hex3 => HEX3,
        hex4 => HEX4,
        hex5 => HEX5,
        hex6 => HEX6,
        hex7 => HEX7,
        ledr => LEDR,
        end_game => end_game,
        end_time => end_time,
        end_round => end_round,
        end_FPGA => end_FPGA
    );

    -- controlador (associação por nome para coincidir com a entity controle)
    CTRL_inst : controle
    PORT MAP(
        R1 => R1,
        R2 => R2,
        E1 => E1,
        E2 => E2,
        E3 => E3,
        E4 => E4,
        E5 => E5,
        clock => CLOCK_50,
        enter => enter,
        reset => reset,
        end_FPGA => end_FPGA,
        end_game => end_game,
        end_time => end_time,
        end_round => end_round
    );
END circuito;