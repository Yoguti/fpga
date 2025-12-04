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
        PE <= EA;
        R1 <= '0';
        R2 <= '0';
        E1 <= '0';
        E2 <= '0';
        E3 <= '0';
        E4 <= '0';
        E5 <= '0';

        CASE EA IS
            WHEN Init =>
                -- Descrição: Reseta o sistema.
                -- Ação: Passa diretamente para Setup.
                -- Sinais: Ativar Resets (exemplo: R1 e R2)
                R1 <= '1';
                R2 <= '1';

                PE <= Setup;

            WHEN Setup =>
                -- Descrição: Usuário escolhe Nível e Sequência nos Switches.
                -- Saída: Aguarda usuário apertar Enter (BTN1).

                -- Se apertar Enter, começa o jogo
                IF enter = '1' THEN
                    PE <= Play_FPGA;
                ELSE
                    PE <= Setup;
                END IF;

            WHEN Play_FPGA =>
                -- Descrição: Mostra a sequência nos Displays.
                -- Saída: Aguarda o tempo terminar (end_FPGA).

                -- Ativar sinais necessários para exibir a ROM e contar tempo
                -- Exemplo (hipotético): E2 <= '1'; 

                IF end_FPGA = '1' THEN
                    PE <= Play_user;
                ELSE
                    PE <= Play_FPGA;
                END IF;

            WHEN Play_user =>
                -- Descrição: Usuário tenta reproduzir a sequência. Tem 10s.
                -- Saída: Apaga displays, habilita switches do usuário.

                -- Habilitar contagem de 10s e leitura dos switches
                -- Exemplo: E3 <= '1'; 

                IF end_time = '1' THEN
                    -- Se o tempo acabar, perdeu a vez -> Result
                    PE <= Result;
                ELSIF enter = '1' THEN
                    -- Se apertar Enter a tempo -> Count_round
                    PE <= Count_round;
                ELSE
                    PE <= Play_user;
                END IF;

            WHEN Count_round =>
                -- Descrição: Incrementa a rodada.
                -- Transição direta para Check.

                E4 <= '1'; -- Exemplo: sinal que incrementa o Counter_round

                PE <= Check;

            WHEN Check =>
                -- Descrição: Verifica se acabou o jogo ou se desconta pontos.
                -- O Datapath já calcula os erros e atualiza bonus.

                -- Verifica condições de parada
                IF (end_round = '1') OR (end_game = '1') THEN
                    PE <= Result;
                ELSE
                    PE <= SWait; -- Vai para espera entre rodadas
                END IF;

            WHEN SWait =>
                -- Espera usuário apertar Enter para próxima rodada.

                IF enter = '1' THEN
                    PE <= Play_FPGA; -- Volta para mostrar nova sequência
                ELSE
                    PE <= SWait;
                END IF;

            WHEN Result =>
                -- Mostra o resultado final.
                -- Fica até usuário reiniciar para jogar de novo.

                -- Ativar mux para mostrar pontos nos HEX
                -- Exemplo: E5 <= '1';

                IF enter = '1' THEN
                    PE <= Init; -- Reinicia o jogo
                ELSE
                    PE <= Result;
                END IF;

            WHEN OTHERS =>
                PE <= Init;
        END CASE;
    END PROCESS;

END bhv;