LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;

ENTITY datapath IS
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
END ENTITY;

ARCHITECTURE arc OF datapath IS
    -------------------------------SIGNALS-------------------------------
    -- contadores
    SIGNAL tempo, X : STD_LOGIC_VECTOR(3 DOWNTO 0);

    -- FSM_clock
    SIGNAL CLK_1Hz, CLK_050Hz, CLK_033Hz, CLK_025Hz, CLK_020Hz : STD_LOGIC;

    -- Logica combinacional
    SIGNAL RESULT : STD_LOGIC_VECTOR(7 DOWNTO 0);

    -- Registradores
    SIGNAL SEL : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL USER : STD_LOGIC_VECTOR(14 DOWNTO 0);
    SIGNAL Bonus, Bonus_reg : STD_LOGIC_VECTOR(3 DOWNTO 0);

    -- ROMs
    SIGNAL CODE_aux : STD_LOGIC_VECTOR(14 DOWNTO 0);
    SIGNAL CODE : STD_LOGIC_VECTOR(31 DOWNTO 0);

    -- COMP
    SIGNAL erro : STD_LOGIC_VECTOR(14 DOWNTO 0);
    SIGNAL erro_numerico : STD_LOGIC_VECTOR(3 DOWNTO 0);

    -- NOR enables displays
    SIGNAL E23, E25, E12 : STD_LOGIC;

    -- decodificadores / displays (7-seg)
    SIGNAL sdec7, sdec6, sdec5, sdec4, sdec3, sdec2, sdec1, sdec0 : STD_LOGIC_VECTOR(6 DOWNTO 0);
    SIGNAL sdec7_f, sdec6_f, sdec5_f, sdec4_f, sdec3_f, sdec2_f, sdec1_f, sdec0_f : STD_LOGIC_VECTOR(6 DOWNTO 0); -- Sinais de limpeza (para todos)
    SIGNAL sdec_result_hi, sdec_result_lo : STD_LOGIC_VECTOR(6 DOWNTO 0);
    SIGNAL sdec_tempo : STD_LOGIC_VECTOR(6 DOWNTO 0);
    SIGNAL sdec_sel_seq, sdec_sel_level : STD_LOGIC_VECTOR(6 DOWNTO 0);
    SIGNAL char_C, char_t, char_L, apagado : STD_LOGIC_VECTOR(6 DOWNTO 0);
    -- sinais pra contcatenacao
    SIGNAL sel_seq_sig  : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL sel_level_sig: STD_LOGIC_VECTOR(3 DOWNTO 0);

    -- Mux/aux displays
    SIGNAL smuxhex7, smuxhex6, smuxhex5, smuxhex4, smuxhex3, smuxhex2, smuxhex1, smuxhex0 : STD_LOGIC_VECTOR(6 DOWNTO 0);

    -- decoders for LEDs (termometrico)
    SIGNAL stermo_round, stermo_bonus : STD_LOGIC_VECTOR(15 DOWNTO 0);

    -- saida ROMs
    SIGNAL srom0, srom1, srom2, srom3 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL srom0a, srom1a, srom2a, srom3a : STD_LOGIC_VECTOR(14 DOWNTO 0);

    -- FSM_clock aux
    SIGNAL E2orE3 : STD_LOGIC;
	-------------------------------COMPONENTS-------------------------------
	COMPONENT counter_time IS
		PORT (
			R, E, clock : IN STD_LOGIC;
			Q : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			tc : OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT counter_round IS
		PORT (
			R, E, clock : IN STD_LOGIC;
			Q : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			tc : OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT decoder_termometrico IS
		PORT (
			X : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			S : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT FSM_clock_de2 IS
		PORT (
			reset, E : IN STD_LOGIC;
			clock : IN STD_LOGIC;
			CLK_1Hz, CLK_050Hz, CLK_033Hz, CLK_025Hz, CLK_020Hz : OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT FSM_clock_emu IS
		PORT (
			reset, E : IN STD_LOGIC;
			clock : IN STD_LOGIC;
			CLK_1Hz, CLK_050Hz, CLK_033Hz, CLK_025Hz, CLK_020Hz : OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT decod7seg IS
		PORT (
			C : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			F : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT d_code IS
		PORT (
			C : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			F : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT mux2x1_7bits IS
		PORT (
			E0, E1 : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
			sel : IN STD_LOGIC;
			saida : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT mux2x1_16bits IS
		PORT (
			E0, E1 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			sel : IN STD_LOGIC;
			saida : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT mux4x1_1bit IS
		PORT (
			E0, E1, E2, E3 : IN STD_LOGIC;
			sel : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			saida : OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT mux4x1_15bits IS
		PORT (
			E0, E1, E2, E3 : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
			sel : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			saida : OUT STD_LOGIC_VECTOR(14 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT mux4x1_32bits IS
		PORT (
			E0, E1, E2, E3 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			sel : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			saida : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT registrador_sel IS
		PORT (
			R, E, clock : IN STD_LOGIC;
			D : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			Q : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT registrador_user IS
		PORT (
			R, E, clock : IN STD_LOGIC;
			D : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
			Q : OUT STD_LOGIC_VECTOR(14 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT registrador_bonus IS
		PORT (
			S, E, clock : IN STD_LOGIC;
			D : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			Q : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT COMP_erro IS
		PORT (
			E0, E1 : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
			diferente : OUT STD_LOGIC_VECTOR(14 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT COMP_end IS
		PORT (
			E0 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			endgame : OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT subtracao IS
		PORT (
			E0 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			E1 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			resultado : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT logica IS
		PORT (
			round, bonus : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			nivel : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			points : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT ROM0 IS
		PORT (
			address : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			output : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT ROM1 IS
		PORT (
			address : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			output : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT ROM2 IS
		PORT (
			address : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			output : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT ROM3 IS
		PORT (
			address : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			output : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT ROM0a IS
		PORT (
			address : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			output : OUT STD_LOGIC_VECTOR(14 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT ROM1a IS
		PORT (
			address : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			output : OUT STD_LOGIC_VECTOR(14 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT ROM2a IS
		PORT (
			address : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			output : OUT STD_LOGIC_VECTOR(14 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT ROM3a IS
		PORT (
			address : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			output : OUT STD_LOGIC_VECTOR(14 DOWNTO 0)
		);
	END COMPONENT;

	-- Somadores bit a bit
	COMPONENT bit_sum IS
		PORT (
			entrada : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
			soma : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
		);
	END COMPONENT;
	-- -------------------------------COMEÇO DO CÓDIGO-------------------------------

BEGIN

	-------------------------------FSM_CLOCK-------------------------------
	--freq_de2: FSM_clock_de2 port map(R1, E2orE3, clk, CLK_1Hz, CLK_050Hz, CLK_033Hz, CLK_025Hz, CLK_020Hz); -- Para usar na placa DE2
	freq_emu : FSM_clock_emu PORT MAP(R1, E2orE3, clk, CLK_1Hz, CLK_050Hz, CLK_033Hz, CLK_025Hz, CLK_020Hz); -- Para usar no emulador
	-- Lógica auxiliar para clock enable e sinais
	E2orE3 <= E2 OR E3;

	-- Definição das letras para os displays
	-- t: segmentos f,e,d,g ON (0000111)
	char_t <= "0000111";
	-- L: segmentos f,e,d ON (1000111)
	char_L <= "1000111";
	-- C: segmentos a,f,e,d ON (usamos o d_code com entrada "1100" = 12)
	-- Apagado (1111111)
	apagado <= "1111111";

    sdec7_f <= apagado WHEN E2 = '0' ELSE sdec7;
    sdec6_f <= apagado WHEN E2 = '0' ELSE sdec6;
    sdec5_f <= apagado WHEN E2 = '0' ELSE sdec5;
    sdec4_f <= apagado WHEN E2 = '0' ELSE sdec4;
    sdec3_f <= apagado WHEN E2 = '0' ELSE sdec3;
    sdec2_f <= apagado WHEN E2 = '0' ELSE sdec2;
    sdec1_f <= apagado WHEN E2 = '0' ELSE sdec1;
    sdec0_f <= apagado WHEN E2 = '0' ELSE sdec0;

	-------------------------------CLOCK E TEMPO-------------------------------
	-- Mux do Clock (Seleciona frequência baseado no nível)
	-- Seleciona qual saída do FSM_clock vai para end_FPGA
	I_MUX_CLOCK : mux4x1_1bit PORT MAP(CLK_025Hz, CLK_025Hz, CLK_033Hz, CLK_050Hz, SEL(1 DOWNTO 0), end_FPGA);

	-------------------------------BLOCOS DE REGISTRADORES E CONTADORES-------------------------------

	I_REG_SEL : registrador_sel PORT MAP(R2, E1, clk, SW(3 DOWNTO 0), SEL);
	I_REG_USER : registrador_user PORT MAP(R2, E3, clk, SW(14 DOWNTO 0), USER);
	I_REG_BONUS : registrador_bonus PORT MAP(R2, E4, clk, Bonus, Bonus_reg);

	I_COUNT_TIME : counter_time PORT MAP(R1, E3, CLK_1Hz, tempo, end_time);
	I_COUNT_ROUND : counter_round PORT MAP(R2, E4, clk, X, end_round);

	----------------------------------------------------------------------------
	-- 3. MEMÓRIAS (ROMs)

	-- Instancia as 4 ROMs Visuais
	I_ROM0 : ROM0 PORT MAP(X, srom0);
	I_ROM1 : ROM1 PORT MAP(X, srom1);
	I_ROM2 : ROM2 PORT MAP(X, srom2);
	I_ROM3 : ROM3 PORT MAP(X, srom3);

	-- MUX 4x1 para escolher a ROM Visual (Controlado por SEL(3..2))
	I_MUX_CODE : mux4x1_32bits PORT MAP(srom0, srom1, srom2, srom3, SEL(3 DOWNTO 2), CODE);

	-- Instancia as 4 ROMs de Gabarito
	I_ROM0a : ROM0a PORT MAP(X, srom0a);
	I_ROM1a : ROM1a PORT MAP(X, srom1a);
	I_ROM2a : ROM2a PORT MAP(X, srom2a);
	I_ROM3a : ROM3a PORT MAP(X, srom3a);

	-- MUX 4x1 para escolher a ROM Gabarito
	I_MUX_AUX : mux4x1_15bits PORT MAP(srom0a, srom1a, srom2a, srom3a, SEL(3 DOWNTO 2), CODE_aux);

	----------------LÓGICA DE PONTUAÇÃO E ERRO--------------------------------------
	I_COMP_ERRO : COMP_erro PORT MAP(CODE_aux, USER, erro);
	I_BIT_SUM : bit_sum PORT MAP(erro, erro_numerico);
	I_SUB : subtracao PORT MAP(Bonus_reg, erro_numerico, Bonus);
	I_COMP_END : COMP_end PORT MAP(Bonus_reg, end_game);
	I_LOGICA : logica PORT MAP(X, Bonus_reg, SEL(1 DOWNTO 0), RESULT);

	--------------------DECODIFICADORES AUXILIARES-----------------------------------

	-- Decodificadores da SEQUENCIA PRINCIPAL (CODE) para os 8 displays
	D7 : d_code PORT MAP(CODE(31 DOWNTO 28), sdec7);
	D6 : d_code PORT MAP(CODE(27 DOWNTO 24), sdec6);
	D5 : d_code PORT MAP(CODE(23 DOWNTO 20), sdec5);
	D4 : d_code PORT MAP(CODE(19 DOWNTO 16), sdec4);
	D3 : d_code PORT MAP(CODE(15 DOWNTO 12), sdec3);
	D2 : d_code PORT MAP(CODE(11 DOWNTO 8), sdec2);
	D1 : d_code PORT MAP(CODE(7 DOWNTO 4), sdec1);
	D0 : d_code PORT MAP(CODE(3 DOWNTO 0), sdec0);

	-- Decodificadores de STATUS (Tempo, Resultado, Nível)
	DT : decod7seg PORT MAP(tempo, sdec_tempo);

	-- Resultado Final (2 dígitos)
	DR_H : decod7seg PORT MAP(RESULT(7 DOWNTO 4), sdec_result_hi);
	DR_L : decod7seg PORT MAP(RESULT(3 DOWNTO 0), sdec_result_lo);

	-- Concatena "00" antes dos 2 bits de seleção para formar 4 bits (atribuições concorrentes)
    sel_seq_sig   <= "00" & SEL(3 DOWNTO 2);
    sel_level_sig <= "00" & SEL(1 DOWNTO 0);

    -- Setup: Mostra qual sequencia e qual nivel foi escolhido
    DS_SEQ : decod7seg PORT MAP(sel_seq_sig, sdec_sel_seq);
    DS_LVL : decod7seg PORT MAP(sel_level_sig, sdec_sel_level);

	-- Gera a letra "C" (Code) usando o d_code com entrada 12 (1100)
	DC_C : d_code PORT MAP("1100", char_C);

	------------------- MUXES FINAIS DOS DISPLAYS--------------------------------	

	-- HEX7: Mostra CODE ou RESULTADO HI (Sel: E5)
    MX_H7 : mux2x1_7bits PORT MAP(sdec7_f, sdec_result_hi, E5, hex7);

    -- HEX6: Mostra CODE ou RESULTADO LO (Sel: E5)
    MX_H6 : mux2x1_7bits PORT MAP(sdec6_f, sdec_result_lo, E5, hex6);

    -- HEX5: Mostra CODE ou Letra 't' (Sel: E3)
    MX_H5 : mux2x1_7bits PORT MAP(sdec5_f, char_t, E3, hex5);

    -- HEX4: Mostra CODE ou Contagem Tempo (Sel: E3)
    MX_H4 : mux2x1_7bits PORT MAP(sdec4_f, sdec_tempo, E3, hex4);

    -- HEX3: Mostra CODE ou Letra 'C' (Sel: E1)
    MX_H3 : mux2x1_7bits PORT MAP(sdec3_f, char_C, E1, hex3);

    -- HEX2: Mostra CODE ou Indice da Sequencia (Sel: E1)
    MX_H2 : mux2x1_7bits PORT MAP(sdec2_f, sdec_sel_seq, E1, hex2);

    -- HEX1: Mostra CODE ou Letra 'L' (Sel: E1)
    MX_H1 : mux2x1_7bits PORT MAP(sdec1_f, char_L, E1, hex1);

    -- HEX0: Mostra CODE ou Indice do Nivel (Sel: E1)
    MX_H0 : mux2x1_7bits PORT MAP(sdec0_f, sdec_sel_level, E1, hex0);

	------------------------LEDS TERMOMÉTRICOS------------------------------
	-- Decodificador para Rodadas (Round)
	DEC_ROUND : decoder_termometrico PORT MAP(X, stermo_round);

	-- Decodificador para Bônus
	DEC_BONUS : decoder_termometrico PORT MAP(Bonus_reg, stermo_bonus);

	-- Mux para escolher o que mostrar nos LEDs (SW17 decide)
	MX_LEDR : mux2x1_16bits PORT MAP(stermo_round, stermo_bonus, SW(17), ledr);

END arc;