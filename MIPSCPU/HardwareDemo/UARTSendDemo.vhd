library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity UARTSendDemo is
	port ( 
		clock : in std_logic;
		reset : in std_logic;
		rdn : out std_logic;
		clock_divided : out  STD_LOGIC;
		data_ready : in std_logic;
		tbre : in std_logic;
		tsre : in std_logic;
		disp : out std_logic;
		wrn : out std_logic;	
		data_bus_1 : inout std_logic_vector(7 downto 0);
		data_bus_1_ce : out std_logic;
		data_bus_1_oe : out std_logic;
		data_bus_1_we : out std_logic;
		output : out std_logic_vector(7 downto 0)
	);
end UARTSendDemo;

architecture Behavioral of UARTSendDemo is
	signal counter: std_logic_vector(25 downto 0);
	signal state : std_logic_vector(2 downto 0);
	signal val : std_logic_vector(7 downto 0);
	signal zero_wait : std_logic_vector(5 downto 0);
	signal wait2 : std_logic_vector(5 downto 0);
	signal current_char : std_logic_vector(7 downto 0);
begin
	process(clock, reset)
	begin
		if reset = '0' then
			--data_bus_1 <= "01100110";
			data_bus_1_ce <= '1';
			data_bus_1_oe <= '1';
			data_bus_1_we <= '1';
			state <= "000";
			rdn <= '1';
			wrn <= '1';
			val <= "01100110";
			val <= ( others => '0' );
			zero_wait <= (others => '0');
			wait2 <= (others => '0');
			current_char <= "00100000";
		elsif rising_edge(clock) then
			if state = "000" then
				rdn <= '1';
				wrn <= '1';
				data_bus_1_oe <= '1';
				data_bus_1_we <= '1';
				data_bus_1 <= current_char;
				wait2 <= wait2 + 1;
				if wait2 = "111111" then
					wait2 <= (others => '0');
					state <= "010";
					zero_wait <= (others => '0');
					state <= "001";
				end if;
			elsif state = "001" then
				rdn <= '1';
				wrn <= '0';
				zero_wait <= zero_wait + 1;
				if zero_wait = "111111" then
					--output(7 downto 3) <= data_bus_1(7 downto 3);
					state <= "010";
				end if;
			elsif state = "010" then
				rdn <= '1';
				wrn <= '1';
				data_bus_1_oe <= '0';
				data_bus_1_we <= '1';
				if tbre = '1' then
					state <= "011";
				end if;
			elsif state = "011" then
				rdn <= '1';
				wrn <= '1';
				if tsre = '1' then
					val <= val + 1;
					if current_char(7) = '0' and current_char(6) = '0' then
						current_char <= current_char + 1;
						state <= "000";
					else
						state <= "111";
					end if;
				end if;
			elsif state = "111" then
			end if;
			counter <= counter + 1;
			clock_divided <= counter(21);
			disp <= data_ready;
			output(7 downto 3) <= data_bus_1(7 downto 3);
			output(2 downto 0) <= state;
		end if;
	end process;
end architecture;
