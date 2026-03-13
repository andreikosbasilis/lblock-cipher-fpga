library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity p_func is
    port(
        Z: in std_logic_vector(31 downto 0);
        U: out std_logic_vector(31 downto 0));
end entity;

architecture rtl of p_func is

begin

	U(3 downto 0) <= Z(7 downto 4);  -- U0 = Z1
	U(7 downto 4) <= Z(15 downto 12); -- U1 = Z3
	U(11 downto 8) <= Z(3 downto 0); -- U2 = Z0
	U(15 downto 12) <= Z(11 downto 8); -- U3 = Z2
	U(19 downto 16) <= Z(23 downto 20); -- U4 = Z5
	U(23 downto 20) <= Z(31 downto 28);  -- U5 = Z7
	U(27 downto 24) <= Z(19 downto 16); -- U6 = Z4
	U(31 downto 28) <= Z(27 downto 24); -- U7 = Z6
end architecture;
