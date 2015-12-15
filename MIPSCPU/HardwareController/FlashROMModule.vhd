library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.MIPSCPU.all;

entity FlashRom is
	port (
		-- Connect with other CPU Parts
		clock : in std_logic;
		reset : in std_logic;
		writeEnable : in std_logic;
		readEnable : in std_logic;
		eraseEnable : in std_logic;
		dataDisplay : out std_logic_vector(15 downto 0);
		dataControl : in std_logic_vector(15 downto 0);
		address : in std_logic_vector(22 downto 0);
		readyStatus : out ReadyStatus_t;
		stateDbg : out std_logic_vector(3 downto 0);
		-- Connect with flash ROM
		flashByte : out std_logic;
		flashVPEN : out std_logic;
		flashCE, flashOE, flashWE : out std_logic;
		flashRP : out std_logic;
		flashAddress : out std_logic_vector(22 downto 0);
		flashData : inout std_logic_vector(15 downto 0)
	);
end entity;

architecture Behavioral of FlashRom is
	signal operationState : std_logic_vector(1 downto 0) := "00";
	-- 00: not busy 01:reading 10: erasing 11: writing
	signal state : std_logic_vector(3 downto 0);
	
begin
	stateDbg <= state;
	flashByte <= '1';
	flashVPEN <= '1';
	flashRP <= '1';
	
	process (clock, reset)
	begin
		if operationState = "00" then
			readyStatus <= STATUS_READY;
		else
			readyStatus <= STATUS_BUSY;
		end if;
		
		if reset = '0' then
			operationState <= "00";
			state <= "0000";
			flashData <= (others => 'Z');
		elsif rising_edge(clock) then
			-- Read Flash ROM
			if operationState = "00" and readEnable = '0' and writeEnable = '1' and eraseEnable = '1' and state = "0000" then
				flashCE <= '0';
				flashWE <= '0';
				state <= "0001";
				operationState <= "01";
			elsif operationState = "01" then
				case state is
					when "0001" => 
						flashData <= X"00FF";
						flashWE <= '1';
						state <= "0010";
					when "0010" => 
						flashOE <= '0';
						state <= "0011";
					when "0011" => 
						flashAddress <= address;
						flashData <= (others => 'Z');
						state <= "0100";
					when "0100" => 
						dataDisplay <= flashData;
						flashOE <= '1';
						state <= "0000";
					when others =>
						flashCE <= '1';
						flashWE <= '1';
						flashOE <= '1';
						state <= "0000";
						operationState <= "00";
				end case;

			-- Erase
			elsif operationState = "00" and readEnable = '1' and writeEnable = '1' and eraseEnable = '0' and state = "0000" then
				flashWE <= '0';
				flashCE <= '0';
				state <= "0001";
				operationState <= "10";
			elsif operationState = "10" then
				case state is
					when "0001" => 
						flashData <= X"0020";
						state <= "1111";
					when "1111" =>
						flashWE <= '1';
						state <= "0010";
					when "0010" => 
						flashWE <= '0';
						state <= "0011";
					when "0011" => 
						flashAddress <= address;
						flashData <= X"00D0";
						state <= "0100";
					when "0100" => 
						flashWE <= '1';
						state <= "0101";
					-- Confirm
					when "0101" =>
						flashWE <= '0';
						flashData <= X"0070";
						state <= "0110";
					when "0110" =>
						flashWE <= '1';
						state <= "0111";
					when "0111" =>
						flashOE <= '0';
						flashData <= (others => 'Z');
						state <= "1000";
					when "1001" =>
						if flashData(7) = '1' then
							state <= "0000";
							operationState <= "00";
						else
							state <= "0101";
						end if;
					when others =>
						flashWE <= '1';
						flashCE <= '1';
						flashOE <= '1';
						state <= "0000";
						operationState <= "00";
				end case;	
						
			-- Write
			elsif operationState = "00" and readEnable = '1' and writeEnable = '0' and eraseEnable = '1' and state = "0000" then
				flashData <= X"0040";
				--flashWE <= '0';
				state <= "0001";
				operationState <= "11";
			elsif operationState = "11" then
				case state is
					when "0001" =>
						flashWE <= '1';
						state <= "0010";
					when "0010" =>
						flashWE <= '0';
						state <= "0011";
					when "0011" =>
						flashAddress <= address;
						flashData <= dataControl;
						state <= "0100";
					when "0100" =>
						flashWE <= '1';
						state <= "0101";
					-- Confirm
					when "0101" =>
						flashWE <= '0';
						flashData <= X"0070";
						state <= "0110";
					when "0110" =>
						flashWE <= '1';
						state <= "0111";
					when "0111" =>
						flashData <= (others => 'Z');
						state <= "1000";
					when "1000" =>
						flashOE <= '0';
						state <= "1001";
					when "1001" =>
						flashOE <= '1';
						if flashData(7) = '1' then
							state <= "1010";
							--operationState <= "00";
						else
							state <= "0101";
						end if;
					when "1010" =>
						flashWE <= '0';
						state <= "1011";
					when "1011" =>
						flashData <= x"00FF";
						state <= "1100";
					when "1100" =>
						flashWE <= '1';
						state <= "0000";
						operationState <= "00";
					when others =>
						flashWE <= '1';
						flashCE <= '1';
						flashOE <= '1';
						state <= "0000";
						operationState <= "00";
				end case;
			end if;
		end if;
	end process;
	
end architecture;
