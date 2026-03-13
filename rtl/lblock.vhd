library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.memory_pkg.all;

entity lblock is
    port(clk: in std_logic;
	reset: in std_logic;
        M: in std_logic_vector(63 downto 0);
	Key: in std_logic_vector(79 downto 0);
	enable: in std_logic;
	current_round: in integer range 0 to 32;
	current_sub_key: out std_logic_vector(31 downto 0);
	key_memory: out memory_type;
        U: out std_logic_vector(63 downto 0));
end entity;

architecture rtl of lblock is

component f_function 
    port(
	enable: in std_logic;
        current_X: in std_logic_vector(31 downto 0);
		sub_Key: in std_logic_vector(31 downto 0);
        U: out std_logic_vector(31 downto 0));
end component;

component key_scheduling
    port(clk : in  std_logic;
        reset  : in  std_logic;  
        enable: in  std_logic; 
        master_key_in: in  std_logic_vector(79 downto 0);
		current_round: in integer range 0 to 32;
	key_memory: out memory_type;
        round_subkey : out std_logic_vector(31 downto 0)); 
end component;


	signal X0: std_logic_vector(31 downto 0);
	signal X0_shifted: std_logic_vector(31 downto 0);
	signal X1: std_logic_vector(31 downto 0);
	signal out_f: std_logic_vector(31 downto 0);
	signal sub_Key: std_logic_vector(31 downto 0);
	signal next_x : std_logic_vector(31 downto 0);

begin

	X1 <= M(63 downto 32);

	X0 <= M(31 downto 0);
	X0_shifted <= X0(23 downto 0) & X0(31 downto 24);

	KEY_SCHEDULE: key_scheduling
	port map(
		clk=>clk,
		reset=>reset,
		enable=>enable,
		master_key_in=>Key,
		key_memory=>key_memory,
		current_round=>current_round,
		round_subkey=>sub_Key);

	F_FUNC: f_function
	port map(
		enable=>enable,
		current_X => X1,
		sub_Key => sub_Key,
		U => out_f);
	
	
			
		next_x <= out_f xor X0_shifted;

		U <= (X1 & next_x) when current_round = 32 else
		next_x & X1;
			
		
	
	current_sub_key <= sub_Key;
end architecture;

