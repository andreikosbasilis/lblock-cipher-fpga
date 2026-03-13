library ieee;
use ieee.std_logic_1164.all;
use work.memory_pkg.all;
entity lblock_top_tb is
end entity;

architecture sim of lblock_top_tb is
    -- Signals
    signal clk    : std_logic := '0';
    signal reset  : std_logic := '0';
    signal start  : std_logic := '0';
    signal use_key_from_input: std_logic := '0';
    signal encr_decr :  std_logic:= '0';
    signal enable_key_gen: std_logic := '0';
    signal enable_decryption : std_logic := '0';
    signal Plain  : std_logic_vector(63 downto 0);
    signal Key    : std_logic_vector(79 downto 0);
    signal key_mem_input : std_logic_vector(31 downto 0);
    signal Ready  : std_logic;
    signal sub_key: std_logic_vector(31 downto 0);
    signal Cipher : std_logic_vector(63 downto 0);
    signal decrypted_plaintext : std_logic_vector(63 downto 0);
    constant clk_period : time := 10 ns;

begin
    -- Instantiate Top Level
    uut: entity work.lblock_full
        port map (
            clk => clk, reset => reset, start => start, encr_decr => encr_decr,
	    Plain => Plain, Key => Key, current_key_mem_input => key_mem_input, use_key_from_input => use_key_from_input,
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
        Plain <= x"0123456789abcdef";
        Key   <= x"0123456789abcdeffedc";
	use_key_from_input <= '0';
        encr_decr  <= '0'; -- Encrypt
        start <= '1'; -- Trigger FSM
        
	wait for clk_period;
	--enable_key_gen <= '1';

	wait for clk_period;


        wait until Ready = '1';
	wait for clk_period;
	encr_decr <= '1';
	--enable_key_gen <= '0';

	wait for clk_period;

	--enable_decryption <= '1';

        --start <= '0'; -- Acknowledge
        
        -- Check result (Expected: 4b7179d8ebee0c26)
        assert (Cipher = x"4B7179D8EBEE0C26")
            report "Encryption Failed! Check your subkeys or S-boxes."
            severity error;

        report "Simulation Finished Successfully!" severity note;
        wait;
    end process;
end architecture;

