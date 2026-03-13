library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity S_func is
    port(r: in std_logic_vector(31 downto 0);
        g: out std_logic_vector(31 downto 0));
end entity;

architecture rtl of S_func is
    -- 2D array for S-boxes s0 through s7 [cite: 135]
    type s_box is array (0 to 15) of std_logic_vector(3 downto 0);
	signal s0,s1,s2,s3,s4,s5,s6,s7 : s_box;

	signal s7_index,s6_index,s5_index,s4_index,s3_index,s2_index,s1_index,s0_index: integer range 0 to 15;
	signal s_out: unsigned(31 downto 0);

begin
s0<= ("1110", "1001", "1111", "0000", "1101", "0100", "1010", "1011", "0001", "0010", "1000", "0011", "0111", "0110", "1100", "0101");
s1<= ("0100", "1011", "1110", "1001", "1111", "1101", "0000", "1010", "0111", "1100", "0101", "0110", "0010", "1000", "0001", "0011");
s2<= ("0001", "1110", "0111", "1100", "1111", "1101", "0000", "0110", "1011", "0101", "1001", "0011", "0010", "0100", "1000", "1010");
s3<= ("0111", "0110", "1000", "1011", "0000", "1111", "0011", "1110", "1001", "1010", "1100", "1101", "0101", "0010", "0100", "0001");
s4<= ("1110", "0101", "1111", "0000", "0111", "0010", "1100", "1101", "0001", "1000", "0100", "1001", "1011", "1010", "0110", "0011");
s5<= ("0010", "1101", "1011", "1100", "1111", "1110", "0000", "1001", "0111", "1010", "0110", "0011", "0001", "1000", "0100", "0101");
s6<= ("1011", "1001", "0100", "1110", "0000", "1111", "1010", "1101", "0110", "1100", "0101", "0111", "0011", "1000", "0001", "0010");
s7<= ("1101", "1010", "1111", "0000", "1110", "0100", "1001", "1011", "0010", "0001", "1000", "0011", "0111", "0101", "1100", "0110");

	
	s7_index <= to_integer(unsigned(r(31 downto 28)));
	s6_index <= to_integer(unsigned(r(27 downto 24)));
	s5_index <= to_integer(unsigned(r(23 downto 20)));
	s4_index <= to_integer(unsigned(r(19 downto 16)));
	s3_index <= to_integer(unsigned(r(15 downto 12)));
	s2_index <= to_integer(unsigned(r(11 downto 8)));
	s1_index <= to_integer(unsigned(r(7 downto 4)));
	s0_index <= to_integer(unsigned(r(3 downto 0)));


	s_out(31 downto 28) <= unsigned(s7(s7_index));
	s_out(27 downto 24) <= unsigned(s6(s6_index));
	s_out(23 downto 20) <= unsigned(s5(s5_index));
	s_out(19 downto 16) <= unsigned(s4(s4_index));
	s_out(15 downto 12) <= unsigned(s3(s3_index));
	s_out(11 downto 8) <= unsigned(s2(s2_index));
	s_out(7 downto 4) <= unsigned(s1(s1_index));
	s_out(3 downto 0) <= unsigned(s0(s0_index));

	g<=std_logic_vector(s_out);


end architecture;
