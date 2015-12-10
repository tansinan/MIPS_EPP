library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FlashRom is
	port (
		-- Connect with other CPU Parts
		clock: in std_logic;
		writeEnable: in std_logic;
		readEnable: in std_logic;
		dataDisplay: out std_logic_vector(15 downto 0);
		dataControl: in std_logic_vector(15 downto 0);
		address: in std_logic_vector(22 downto 0);
		
		-- Connecct with flash ROM
		flashByte: out std_logic;
		flashVPEN: out std_logic;
		flashCE, flashOE, flashWE: out std_logic;
		flashRP: out std_logic;
		flashAddress: out std_logic_vector(22 downto 0);
		flashData: inout std_logic_vector(15 downto 0)
	);
end entity;

architecture Behavioral of FlashRom is
	signal operationState:std_logic_vector(1 downto 0) := "00";-- 00: not busy 01:reading 10: erasing 11: writing
	
begin
	flashByte <= '1';
	flashVPEN <= '1';
	flashRP <= '1';
	if operationState = "00"
		flashData <= (others => 'Z');
		flashOE <= '1';
	end if;
	
	process (clock)
		variable state:std_logic_vector(4 downto 0)
	begin
		if rising_edge(clock) then
			-- Read Flash ROM
			if operationState = "00" and readEnable = "0" and writeEnable = "1" and state = "0000"
				flashCE <= '0';
				flashWE <= '0';
				state := "0001";
				operationState <= "01";
			elsif operationState = "01"
				case state is
					when "0001" => 
						flashData <= X"00FF";
						flashWE <= '1';
						state := "0010";
					when "0010" => 
						flashOE <= '0';
						state := "0011";
					when "0011" => 
						flashAddress <= address;
						flashData <= (others => 'Z');
						state := "0100";
					when "0100" => 
						dataDisplay <= flashData;
						flashOE <= '1';
						state := "0000";
					when others =>
						flashCE <= '1';
						flashWE <= '1';
						state := "0000";
						operationState <= "00";
				end case;
			elsif operationState = "00" and readEnable = "1" and writeEnable = "0" and state = "0000"
				flashWE <= '0';
				flashCE <= '0';
				state := "0001";
				operationState <= "10";
			elsif operationState = "10"
				case state is
					when "0001" => 
						flashData <= X"0020";
						flashWE <= '1';
						state := "0010";
					when "0010" => 
						flashWE <= '0';
						state := "0011";
					when "0011" => 
						flashAddress <= address;
						flashData <= X"00D0";
						state := "0100";
					when "0100" => 
						flashWE <= '1';
						state := "0101";
					-- Confirm
					when "0101" =>
						flashWE <= '0';
						state := "0110";
					when "0110" =>
						flashData <= X"0070";
						flashWE <= '1';
						state := "0111";
					when "0111" =>
						flashOE <= '0';
						flashData <= (others => 'Z');
						state := "1000";
					when "1001" =>
						if flashData(7) = '1'
							state := "0000";
							operationState <= "11";
						else
							state := "0101";
				end case;		
						
			-- Write
			elsif operationState = "11";
				case state is
					when "0000" =>
						flashWE <= '0';
						state := "0001";
					when "0001" =>
						flashData <= X"0040";
						flashWE <= '1';
						state := "0010";
					when "0010" =>
						flashWE <= '0';
						state := "0011";
					when "0011" =>
						flashAddress <= address;
						flashData <= dataControl;
						state := "0100";
					when "0100" =>
						flashWE <= '1';
						state := "0101";
					-- Confirm
					when "0101" =>
						flashWE <= '0';
						state := "0110";
					when "0110" =>
						flashData <= X"0070";
						flashWE <= '1';
						state := "0111";
					when "0111" =>
						flashOE <= '0';
						flashData <= (others => 'Z');
						state := "1000";
					when "1001" =>
						if flashData(7) = '1'
							state := "0000";
							operationState <= "11";
						else
							state := "0101";
					when others =>
						flashWE <= '1';
						flashCE <= '1';
						state := "0000";
						operationState <= "00";
				end case;
			end if;
		end if;
	end process;
	
end architecture;
