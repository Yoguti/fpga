LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY controle IS PORT (
    -- Saidas Datapath
    R1, R2, E1, E2, E3, E4, E5 : OUT STD_LOGIC;

    clock : IN STD_LOGIC;
    enter, reset : IN STD_LOGIC;
    -- BTN1: enter (avança/confirma)
    -- BTN0: reset (reinicia o jogo a qualquer momento)

    -- Status Datapath
    end_FPGA, end_game, end_time, end_round : IN STD_LOGIC
);
END controle;

ARCHITECTURE bhv OF controle IS
    TYPE STATES IS (Init, Setup, Play_FPGA, Play_user, Count_round, Check, SWait, Result);
    SIGNAL EA, PE : STATES;
BEGIN

    P1 : PROCESS (clock, reset)
    BEGIN
        -- Se BTN0 (Reset) for pressionado, volta para Init
        IF reset = '1' THEN
            EA <= Init;
        ELSIF clock'EVENT AND clock = '1' THEN
            EA <= PE;
        END IF;
    END PROCESS;

    -- Lógica de Próximo Estado e Saídas
    P2 : PROCESS (EA, enter, end_FPGA, end_time, end_round, end_game)
    BEGIN
        -- Valores padrão
        PE <= EA;
        R1 <= '0'; R2 <= '0';
        E1 <= '0'; E2 <= '0'; E3 <= '0'; E4 <= '0'; E5 <= '0';

        CASE EA IS
            WHEN Init =>
                R1 <= '1'; -- Reseta Counter Time
                R2 <= '1'; -- Reseta Jogo (Round, Bonus, User)
                PE <= Setup;

            WHEN Setup =>
                E1 <= '1'; -- Habilita salvar SW de Seleção (Nivel/Seq)
                IF enter = '1' THEN
                    PE <= Play_FPGA;
                ELSE
                    PE <= Setup;
                END IF;

            WHEN Play_FPGA =>
                E2 <= '1'; -- Habilita MUX para mostrar a SEQUENCIA (ROM)
                IF end_FPGA = '1' THEN
                    PE <= Play_user;
                ELSE
                    PE <= Play_FPGA;
                END IF;

            WHEN Play_user =>
                E3 <= '1'; -- Habilita MUX do Tempo + Decrementa Timer + Lê Switches User
                IF end_time = '1' THEN
                    PE <= Result; -- Tempo acabou = Game Over ou perde vida
                ELSIF enter = '1' THEN
                    PE <= Count_round; -- Jogador confirmou a entrada
                ELSE
                    PE <= Play_user;
                END IF;

            WHEN Count_round =>
                -- Estado transitorio para incrementar rodada e calcular bonus
                E4 <= '1'; -- Incrementa Round e Atualiza Bonus
                PE <= Check;

            WHEN Check =>
                -- verifica status (logica combinacional resolve end_game/end_round)
                IF (end_round = '1') OR (end_game = '1') THEN
                    PE <= Result;
                ELSE
                    PE <= SWait;
                END IF;

            WHEN SWait =>
                -- Espera entre rodadas (mantém display parado ou apagado)
                IF enter = '1' THEN
                    PE <= Play_FPGA; -- Vai para próxima rodada
                ELSE
                    PE <= SWait;
                END IF;

            WHEN Result =>
                E5 <= '1'; -- Habilita MUX para mostrar RESULTADO (Pontos)
                IF enter = '1' THEN
                    PE <= Init; -- Reinicia tudo
                ELSE
                    PE <= Result;
                END IF;

            WHEN OTHERS =>
                PE <= Init;
        END CASE;
    END PROCESS;

END bhv;