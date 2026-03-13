library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity f_function is
    port(enable: in std_logic;
        current_X: in std_logic_vector(31 downto 0);
	sub_Key: in std_logic_vector(31 downto 0);
        U: out std_logic_vector(31 downto 0));
end entity;

architecture rtl of f_function is

component S_func 
    port(r: in std_logic_vector(31 downto 0);
        g: out std_logic_vector(31 downto 0));
end component;

component p_func 
    port(
        Z: in std_logic_vector(31 downto 0);
        U: out std_logic_vector(31 downto 0));
end component;

signal xor_out, s_out: std_logic_vector(31 downto 0);


begin

	xor_out <= (current_X xor sub_Key) when enable = '1' else
	xor_out;


	S_BOX: S_func	
		port map(r=>xor_out,
			g=>s_out);
			
	P_PART: p_func
		port map(
			Z=>s_out,
			U=>U);


end architecture;

