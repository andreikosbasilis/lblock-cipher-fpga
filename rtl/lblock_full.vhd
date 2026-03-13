library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.memory_pkg.all;

entity lblock_full is
    port(
        clk      : in  std_logic;
        reset    : in  std_logic;
        start    : in  std_logic;
        encr_decr : in std_logic; --0:encryption,1:decryption
    	use_key_from_input: std_logic;
        Plain    : in  std_logic_vector(63 downto 0);
        Key      : in  std_logic_vector(79 downto 0);
	current_key_mem_input : in std_logic_vector(31 downto 0);
        Ready    : out std_logic;
	sub_key  : out std_logic_vector(31 downto 0);
        Cipher   : out std_logic_vector(63 downto 0);
	decrypted_plaintext : out std_logic_vector (63 downto 0) := (others=>'0')
    );
end entity;

architecture fsm of lblock_full is

    type state_type is (STARTING, IDLE, LOAD, LOAD_KEYS, ENCRYPTION, LOAD_DECRYPT, DECRYPT, DONE);
    signal state : state_type := IDLE;

    signal current_data  : std_logic_vector(63 downto 0);
    signal next_round_v  : std_logic_vector(63 downto 0);
    signal sub_key_v  : std_logic_vector(31 downto 0);
    signal round_count   : integer range 0 to 32 := 0;
    signal key_memory : memory_type;
    signal decryption_data : std_logic_vector(63 downto 0);
    signal decryption_round : integer range 0 to 31 := 31;
    signal decryption_next_round : std_logic_vector(63 downto 0);
    signal enable: std_logic;
    signal enable_decryption:  std_logic;
    signal internal_key_memory : memory_type;
    signal total_key_mem_input : memory_type;
    signal key_count: integer range 0 to 32;
    signal active_key_memory : memory_type;

    component lblock
        port(
            clk           : in std_logic;
            reset         : in std_logic;
            M             : in std_logic_vector(63 downto 0);
            Key           : in std_logic_vector(79 downto 0);
	    enable: in std_logic;
            current_round : in integer range 0 to 32;
	    key_memory: out memory_type;
	    current_sub_key: out std_logic_vector(31 downto 0);
            U             : out std_logic_vector(63 downto 0)
        );
    end component;

component lblock_decrypt is
    port(clk,reset : in std_logic;
	C: in std_logic_vector(63 downto 0);
	enable_dec: in std_logic;
	key_memory: in memory_type;
	dec_j: in integer range 0 to 31;
        S: out std_logic_vector(63 downto 0));
end component;


begin

    ROUND_LOGIC: lblock
        port map(
            clk           => clk,
            reset         => reset,
            M             => current_data,
            Key           => Key,
	    enable        => enable,
            current_round => round_count,
	    key_memory    => internal_key_memory,
	    current_sub_key => sub_key_v,
            U             => next_round_v
        );

    DECRYPTION_LOGIC: lblock_decrypt
	port map( clk => clk, reset=>reset,
		C => decryption_data,
		enable_dec => enable_decryption,
		key_memory => active_key_memory,
		dec_j => decryption_round,
		S => decryption_next_round
	);

active_key_memory <= total_key_mem_input when use_key_from_input = '1' else internal_key_memory;

    process(clk, reset)
variable temp_out : std_logic_vector(63 downto 0);
variable temp_subkey: std_logic_vector(31 downto 0);
variable temp_data : std_logic_vector(63 downto 0);
variable decryption_input : std_logic_vector(63 downto 0);
variable decryption_output : std_logic_vector(63 downto 0);


    begin
        if reset = '1' then
            state <= STARTING;
            Ready <= '0';
	    key_count <= 0;
	    decryption_data <= (others => '0');
	    enable <= '0';
	    enable_decryption <= '0';
        elsif rising_edge(clk) then
            case state is

		when STARTING | IDLE =>
                    if state = IDLE then
			Ready <= '1';
		    else
			Ready <= '0';
		    end if;
                    enable <= '0';
                    enable_decryption <= '0';
                    if start = '1' then
                        Ready <= '0';
                        if encr_decr = '0' then
				enable <= '1';
                            state <= LOAD;
			elsif encr_decr = '1' then

                            state <= LOAD_DECRYPT;
                        end if;
                    end if;

                when LOAD =>
                    current_data <= Plain;
                    round_count <= 1;
		  
                    state <= ENCRYPTION;

                when ENCRYPTION =>
                    temp_data := next_round_v;
		    temp_out := current_data;
		    temp_subkey := sub_key_v;
		    current_data <= temp_data;
		    sub_key <= temp_subkey;
		    Cipher <= temp_data;
                    if round_count = 32 then
			enable <= '0';
                        state <= DONE;
                    else
			enable <= '1';
		 	round_count <= round_count + 1;
		    end if;

		when LOAD_KEYS =>
			if key_count < 32 then
				total_key_mem_input(key_count) <= current_key_mem_input;
				key_count <= key_count + 1;
			else
				decryption_round <= 31;
				enable_decryption <= '1';
				state <= DECRYPT;
			end if;

		when LOAD_DECRYPT =>
			if use_key_from_input = '1' then
				decryption_data <= Plain;
				key_count <=0;
				state <= LOAD_KEYS;
			elsif use_key_from_input = '0' then
				decryption_data <= current_data;
				decryption_round <= 31;
				enable_decryption <= '1';
				state <= DECRYPT;
			end if;

		when DECRYPT =>
			decryption_data <= decryption_next_round;

			if decryption_round = 0 then
				decrypted_plaintext <= decryption_next_round;
            			state <= DONE;
			else
				decryption_round <= decryption_round - 1;
			end if;

           	 when DONE =>
                    	Cipher <= current_data;
                    	Ready <= '1';
		    	enable_decryption <='0';
		    	enable <= '0';
		    	state <= IDLE;

            end case;
        end if;
    end process;

end architecture;

