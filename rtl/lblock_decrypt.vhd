library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.memory_pkg.all;

entity lblock_decrypt is
    port(clk,reset : in std_logic;
	C: in std_logic_vector(63 downto 0);
	enable_dec: in std_logic;
	key_memory: in memory_type;
	dec_j: in integer range 0 to 31;
        S: out std_logic_vector(63 downto 0));
end entity;

architecture rtl of lblock_decrypt is

component f_function 
    port(
	enable: in std_logic;
        current_X: in std_logic_vector(31 downto 0);
	sub_Key: in std_logic_vector(31 downto 0);
        U: out std_logic_vector(31 downto 0));
end component;

	signal Xj: std_logic_vector(31 downto 0);
	signal Xj_1: std_logic_vector(31 downto 0);
	signal Xj_2: std_logic_vector(31 downto 0);
	signal out_f: std_logic_vector(31 downto 0);
	signal sub_Key: std_logic_vector(31 downto 0);
	signal xor_out : std_logic_vector(31 downto 0);

begin

	F_FUNC: f_function
	port map(
		enable=>enable_dec,
		current_X => Xj_1,
		sub_Key => sub_Key,
		U => out_f);
	
	sub_Key <= key_memory(dec_j);

	Xj_1 <= C(63 downto 32);
	Xj_2 <= C(31 downto 0);

	xor_out <= out_f xor Xj_2;

	Xj <= std_logic_vector(rotate_right(unsigned(xor_out),8));
	S <=  Xj & Xj_1 when dec_j > 0 else
	Xj_1 & Xj;

end architecture;

