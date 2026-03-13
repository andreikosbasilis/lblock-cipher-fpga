library ieee;
use ieee.std_logic_1164.all;
use work.memory_pkg.all;
entity lblock_top_decrypt_tb is
end entity;

architecture sim of lblock_top_decrypt_tb is
    -- Signals
    signal clk    : std_logic := '0';
    signal reset  : std_logic := '0';
    signal start  : std_logic := '0';
    signal encr_decr :  std_logic:= '0';
    signal use_key_from_input : std_logic := '0';
    signal enable_key_gen: std_logic := '0';
    signal enable_decryption : std_logic := '0';
    signal Plain  : std_logic_vector(63 downto 0);
    signal Key    : std_logic_vector(79 downto 0);
    signal current_key_mem_input : std_logic_vector(31 downto 0);
    signal Ready  : std_logic;
    signal sub_key: std_logic_vector(31 downto 0);
    signal Cipher : std_logic_vector(63 downto 0);
    signal decrypted_plaintext : std_logic_vector(63 downto 0);
    constant clk_period : time := 10 ns;

constant TEST_KEY_MEM : memory_type := (
    -- Indices 0 to 3
    0  => x"01234567", 1  => x"673579BD", 2  => x"C6FB7004", 3  => x"47A2B19C",
    -- Indices 4 to 7
    4  => x"4EBCDF1A", 5  => x"24B8011F", 6  => x"6C58CD3B", 7  => x"916F8C93",
    -- Indices 8 to 11
    8  => x"9F008DB3", 9  => x"92669E47", 10 => x"63C64A7E", 11 => x"A846DA4B",
    -- Indices 12 to 15
    12 => x"9A4F218C", 13 => x"45253EA2", 14 => x"7A6D266A", 15 => x"2690C517",
    -- Indices 16 to 19
    16 => x"399F51ED", 17 => x"C093349E", 18 => x"E86288E2", 19 => x"23A8F706",
    -- Indices 20 to 23
    20 => x"A79A4FA4", 21 => x"8744708B", 22 => x"D27B829B", 23 => x"D427D218",
    -- Indices 24 to 27
    24 => x"5938474F", 25 => x"64C14F56", 26 => x"AAE90D62", 27 => x"7223A595",
    -- Indices 28 to 31
    28 => x"CBA7AAAC", 29 => x"8F86B1CF", 30 => x"6CD2CB29", 31 => x"F5D55639"
);


begin
    -- Instantiate Top Level
    uut: entity work.lblock_full
        port map (
            clk => clk, reset => reset, start => start, encr_decr => encr_decr,
	    Plain => Plain, Key => Key, current_key_mem_input => current_key_mem_input, use_key_from_input => use_key_from_input,
            Ready => Ready, Cipher => Cipher, decrypted_plaintext => decrypted_plaintext
        );

    -- Clock Generation
    clk_process : process
    begin
        clk <= '0'; wait for clk_period/2;
        clk <= '1'; wait for clk_period/2;
    end process;

    -- Stimulus
    process
    begin
        -- Reset system
        reset <= '1';
        wait for 40 ns;
        reset <= '0';
        wait for 20 ns;

        -- Test Vector 2 from Paper
        Plain <= x"4B7179D8EBEE0C26";
	use_key_from_input <= '1';
        encr_decr  <= '1'; -- Encrypt
        start <= '1'; -- Trigger FSM
        
	wait for clk_period*2;

	for i in 0 to 31 loop
		current_key_mem_input <= TEST_KEY_MEM(i);
		wait for clk_period;
	end loop;

        wait until Ready = '1';
	start <= '0';
        -- Check result (Expected: 4b7179d8ebee0c26)
        assert (Cipher = x"4B7179D8EBEE0C26")
            report "Encryption Failed! Check your subkeys or S-boxes."
            severity error;

        report "Simulation Finished Successfully!" severity note;
        wait;
    end process;
end architecture;

