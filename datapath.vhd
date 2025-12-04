library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity datapath is
port(
	-- Entradas de dados
	clk: in std_logic;
	SW: in std_logic_vector(17 downto 0);
	
	-- Entradas de controle
	R1, R2, E1, E2, E3, E4, E5: in std_logic;
	
	-- Saídas de dados
	hex0, hex1, hex2, hex3, hex4, hex5, hex6, hex7: out std_logic_vector(6 downto 0);
	ledr: out std_logic_vector(15 downto 0);
	
	-- Saídas de status
	end_game, end_time, end_round, end_FPGA: out std_logic
);
end entity;

architecture arc of datapath is
---------------------------SIGNALS-----------------------------------------------------------
--contadores
signal tempo, X: std_logic_vector(3 downto 0);
--FSM_clock
signal CLK_1Hz, CLK_050Hz, CLK_033Hz, CLK_025Hz, CLK_020Hz: std_logic;
--Logica combinacional
signal RESULT: std_logic_vector(7 downto 0);
--Registradores
signal SEL: std_logic_vector(3 downto 0);
signal USER: std_logic_vector(14 downto 0);
signal Bonus, Bonus_reg: std_logic_vector(3 downto 0);
--ROMs
signal CODE_aux: std_logic_vector(14 downto 0);
signal CODE: std_logic_vector(31 downto 0);
--COMP
signal erro: std_logic_vector(14 downto 0);
signal erro_numerico : std_logic_vector(3 downto 0);
--NOR enables displays
signal E23, E25, E12: std_logic;

--signals implícitos--

--dec termometrico
signal stermoround, stermobonus, andtermo: std_logic_vector(15 downto 0);
--decoders HEX 7-0
signal sdecod7, sdec7, sdecod6, sdec6, sdecod5, sdecod4, sdec4, sdecod3, sdecod2, sdec2, sdecod1, sdecod0, sdec0: std_logic_vector(6 downto 0);
signal smuxhex7, smuxhex6, smuxhex5, smuxhex4, smuxhex3, smuxhex2, smuxhex1, smuxhex0: std_logic_vector(6 downto 0);
signal edec2, edec0: std_logic_vector(3 downto 0);
--saida ROMs
signal srom0, srom1, srom2, srom3: std_logic_vector(31 downto 0);
signal srom0a, srom1a, srom2a, srom3a: std_logic_vector(14 downto 0);
--FSM_clock
signal E2orE3: std_logic;
---------------------------COMPONENTS-----------------------------------------------------------
component counter_time is 
port(
	R, E, clock: in std_logic;
	Q: out std_logic_vector(3 downto 0);
	tc: out std_logic
);
end component;

component counter_round is
port(
	R, E, clock: in std_logic;
	Q: out std_logic_vector(3 downto 0);
	tc: out std_logic
);
end component;

component decoder_termometrico is
 port(
	X: in  std_logic_vector(3 downto 0);
	S: out std_logic_vector(15 downto 0)
);
end component;

component FSM_clock_de2 is
port(
	reset, E: in std_logic;
	clock: in std_logic;
	CLK_1Hz, CLK_050Hz, CLK_033Hz, CLK_025Hz, CLK_020Hz: out std_logic
);
end component;

component FSM_clock_emu is
port(
	reset, E: in std_logic;
	clock: in std_logic;
	CLK_1Hz, CLK_050Hz, CLK_033Hz, CLK_025Hz, CLK_020Hz: out std_logic
);
end component;

component decod7seg is
port(
	C: in std_logic_vector(3 downto 0);
	F: out std_logic_vector(6 downto 0)
 );
end component;

component d_code is
port(
	C: in std_logic_vector(3 downto 0);
	F: out std_logic_vector(6 downto 0)
 );
end component;

component mux2x1_7bits is
port(
	E0, E1: in std_logic_vector(6 downto 0);
	sel: in std_logic;
	saida: out std_logic_vector(6 downto 0)
);
end component;

component mux2x1_16bits is
port(
	E0, E1: in std_logic_vector(15 downto 0);
	sel: in std_logic;
	saida: out std_logic_vector(15 downto 0)
);
end component;

component mux4x1_1bit is
port(
	E0, E1, E2, E3: in std_logic;
	sel: in std_logic_vector(1 downto 0);
	saida: out std_logic
);
end component;

component mux4x1_15bits is
port(
	E0, E1, E2, E3: in std_logic_vector(14 downto 0);
	sel: in std_logic_vector(1 downto 0);
	saida: out std_logic_vector(14 downto 0)
);
end component;

component mux4x1_32bits is
port(
	E0, E1, E2, E3: in std_logic_vector(31 downto 0);
	sel: in std_logic_vector(1 downto 0);
	saida: out std_logic_vector(31 downto 0)
);
end component;

component registrador_sel is 
port(
	R, E, clock: in std_logic;
	D: in std_logic_vector(3 downto 0);
	Q: out std_logic_vector(3 downto 0) 
);
end component;

component registrador_user is 
port(
	R, E, clock: in std_logic;
	D: in std_logic_vector(14 downto 0);
	Q: out std_logic_vector(14 downto 0) 
);
end component;

component registrador_bonus is 
port(
	S, E, clock: in std_logic;
	D: in std_logic_vector(3 downto 0);
	Q: out std_logic_vector(3 downto 0) 
);
end component;

component COMP_erro is
port(
	E0, E1: in std_logic_vector(14 downto 0);
	diferente: out std_logic_vector(14 downto 0)
);
end component;

component COMP_end is
port(
	E0: in std_logic_vector(3 downto 0);
	endgame: out std_logic
);
end component;

component subtracao is
port(
	E0: in std_logic_vector(3 downto 0);
	E1: in std_logic_vector(3 downto 0);
	resultado: out std_logic_vector(3 downto 0)
);
end component;

component logica is 
port(
	round, bonus: in std_logic_vector(3 downto 0);
	nivel: in std_logic_vector(1 downto 0);
	points: out std_logic_vector(7 downto 0)
);
end component;

component ROM0 is
port(
	address: in std_logic_vector(3 downto 0);
	output : out std_logic_vector(31 downto 0)
);
end component;

component ROM1 is
port(
	address: in std_logic_vector(3 downto 0);
	output : out std_logic_vector(31 downto 0)
);
end component;

component ROM2 is
port(
	address: in std_logic_vector(3 downto 0);
	output : out std_logic_vector(31 downto 0)
);
end component;

component ROM3 is
port(
	address: in std_logic_vector(3 downto 0);
	output : out std_logic_vector(31 downto 0)
);
end component;

component ROM0a is
port(
	address: in std_logic_vector(3 downto 0);
	output : out std_logic_vector(14 downto 0)
);
end component;

component ROM1a is
port(
	address: in std_logic_vector(3 downto 0);
	output : out std_logic_vector(14 downto 0)
);
end component;

component ROM2a is
port(
	address: in std_logic_vector(3 downto 0);
	output : out std_logic_vector(14 downto 0)
);
end component;

component ROM3a is
port(
	address: in std_logic_vector(3 downto 0);
	output : out std_logic_vector(14 downto 0)
);
end component;

-- Somadores bit a bit
component bit_sum is
    port (
        entrada : in  std_logic_vector(14 downto 0);
        soma    : out std_logic_vector(3 downto 0)
    );
end component;


-- COMEÇO DO CODIGO ---------------------------------------------------------------------------------------

begin	

---------------------------FSM_clock--------------------------------------
freq_de2: FSM_clock_de2 port map(R1, E2orE3, clk, CLK_1Hz, CLK_050Hz, CLK_033Hz, CLK_025Hz, CLK_020Hz); -- Para usar na placa DE2
--freq_emu: FSM_clock_emu port map(R1, E2orE3, clk, CLK_1Hz, CLK_050Hz, CLK_033Hz, CLK_025Hz, CLK_020Hz); -- Para usar no emulador

-- o aluno deve interligar todas as componentes seguindo o modelo do datapath dado

end arc;