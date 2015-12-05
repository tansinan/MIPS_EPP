library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library HardwareController;

entity UARTSendDemo is
	port ( 
		clock : in std_logic;
		reset : in std_logic;
		clock_divided : out  STD_LOGIC;
		disp : out std_logic;	
		output : out std_logic_vector(7 downto 0);
		rxd : in std_logic;
		txd : out std_logic
	);
end entity;

architecture Behavioral of UARTSendDemo is
	signal counter: std_logic_vector(25 downto 0);
	signal state : std_logic_vector(2 downto 0);
	signal zero_wait : std_logic_vector(5 downto 0);
	signal wait2 : std_logic_vector(5 downto 0);
	signal current_char : std_logic_vector(7 downto 0);
	signal DATA_STREAM_IN_STB : std_logic;
	signal DATA_STREAM_IN_ACK : std_logic;
	signal DATA_STREAM_OUT_ACK : std_logic;
	signal rdn : std_logic;
	signal wrn : std_logic;
	signal data : std_logic_vector(7 downto 0);
	--signal dataReady : std_logic;
	--signal parityError : std_logic;
	--signal framingError : std_logic;
begin
	UARTController_i : entity work.UART
    generic map (
            BAUD_RATE => 115200,
            CLOCK_FREQUENCY => 50000000
        )
    port map (
		clock => clock,
		reset => not reset,
		DATA_STREAM_IN => data,
		DATA_STREAM_IN_STB => DATA_STREAM_IN_STB,
		DATA_STREAM_IN_ACK => DATA_STREAM_IN_ACK,
		DATA_STREAM_OUT => open,
		DATA_STREAM_OUT_STB => open,
		DATA_STREAM_OUT_ACK => DATA_STREAM_OUT_ACK,
		TX => txd,
		RX => '1'
    );

	process(clock, reset)
	begin
		if reset = '0' then
			state <= "000";
			zero_wait <= (others => '0');
			wait2 <= (others => '0');
			current_char <= "00100000";
			counter <= (others => '0');
			DATA_STREAM_IN_STB <= '1';
		elsif rising_edge(clock) then
			if state = "000" then
				DATA_STREAM_IN_STB <= '0';
				data <= current_char;
				wait2 <= wait2 + 1;
				if wait2 = "111111" then
					wait2 <= (others => '0');
					state <= "010";
					zero_wait <= (others => '0');
					state <= "001";
				else
				end if;
			elsif state = "001" then
				DATA_STREAM_IN_STB <= '1';
				data <= current_char;
				zero_wait <= zero_wait + 1;
				if zero_wait = "111111" then
					--output(7 downto 3) <= data_bus_1(7 downto 3);
					state <= "010";
				end if;
			elsif state = "010" then
				data <= current_char;
				DATA_STREAM_IN_STB <= '1';
				if DATA_STREAM_IN_ACK = '1' then
					state <= "011";
				else
				end if;
			elsif state = "011" then
				data <= current_char;
				DATA_STREAM_IN_STB <= '0';
				if current_char(7) = '0' and current_char(6) = '0' then
					current_char <= current_char + 1;
					state <= "000";
				else
					state <= "111";
				end if;
			elsif state = "111" then
			end if;
			counter <= counter + 1;
			clock_divided <= counter(21);
			disp <= '0';
			output <= data;
			--output(7 downto 3) <= data(7 downto 3);
			--output(2 downto 0) <= state;
			--output <= UARTController_i/txmit/tsr;
		end if;
	end process;
end architecture;
