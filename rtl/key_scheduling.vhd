library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.memory_pkg.all;

entity key_scheduling is
	port (clk : in  std_logic;
        reset  : in  std_logic;  
        enable  : in  std_logic;  -- move to the next subkey 
        master_key_in: in  std_logic_vector(79 downto 0);
	current_round: in integer range 0 to 32;
	key_memory: out memory_type;
        round_subkey : out std_logic_vector(31 downto 0) -- current subkey 
    );
end entity;

architecture rtl of key_scheduling is
    signal whole_key : std_logic_vector(79 downto 0);
    signal sub_key : std_logic_vector(31 downto 0);
    type s_box is array (0 to 15) of std_logic_vector(3 downto 0);
    signal temp_memory : memory_type;
    signal s8,s9: s_box;

begin

s8<= ("1000", "0111", "1110", "0101", "1111", "1101", "0000", "0110", "1011", "1100", "1001", "1010", "0010", "0100", "0001", "0011");
s9<= ("1011", "0101", "1111", "0000", "0111", "0010", "1001", "1101", "0100", "1000", "0001", "1100", "1110", "1010", "0011", "0110");


        process(clk,reset)
        variable temp_key : unsigned(79 downto 0);
	variable round_num: integer range 0 to 32;
        variable s8_index, s9_index : integer range 0 to 15;
    begin
            if reset = '1' then
                whole_key <= (others=>'0');
		sub_key <= (others=>'0');
		key_memory <= (others=>(others=>'0'));
		round_num := 0;
            elsif clk'event and clk='1' and enable ='1' then
			if(round_num < 32) then
				if(round_num < 1) then
					temp_key := unsigned(master_key_in);
					temp_memory(0) <= std_logic_vector(temp_key(79 downto 48));
					round_num := 1;

				else

					temp_key := unsigned(whole_key);	
					-- 1. Perform Rotation
					temp_key := rotate_left(temp_key,29);

					-- 2. Extract nibbles for S-boxes safely
					s9_index := to_integer(temp_key(79 downto 76));
					s8_index := to_integer(temp_key(75 downto 72));

					-- 3. Apply S-boxes
					temp_key(79 downto 76) := unsigned(s9(s9_index));
					temp_key(75 downto 72) := unsigned(s8(s8_index));

					-- 4. XOR with Round Constant
					temp_key(50 downto 46) := temp_key(50 downto 46) xor (to_unsigned(round_num, 5));
					temp_memory(round_num) <= std_logic_vector(temp_key(79 downto 48));

					round_num := round_num + 1;				
				end if;

			else 
				key_memory<=temp_memory;
			end if;
			
			sub_key <= std_logic_vector(temp_key(79 downto 48));
			whole_key <= std_logic_vector(temp_key);
		end if;
    end process;
	round_subkey <= sub_key;
end architecture;



