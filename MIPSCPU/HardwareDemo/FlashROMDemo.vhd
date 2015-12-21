library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.MIPSCPU.all;
use work.HardwareController.all;

entity FlashROMDemo is
	port
	(
		reset : in Reset_t;
		clock : in Clock_t;
		successLight : out std_logic;
		-- Connect with flash ROM
		flashByte : out std_logic;
		flashVPEN : out std_logic;
		flashCE, flashOE, flashWE : out std_logic;
		flashCE1, flashCE2 : out std_logic;
		flashRP : out std_logic;
		flashAddress : out std_logic_vector(22 downto 0);
		flashData : inout std_logic_vector(15 downto 0);
		outputLight : out std_logic_vector(15 downto 0)
	);
end entity;

architecture Behavioral of FlashROMDemo is
    -- Connect with FlashRomModule
    signal writeEnable : std_logic;
    signal readEnable : std_logic;
    signal dataDisplay : std_logic_vector(15 downto 0);
    signal dataControl : std_logic_vector(15 downto 0);
    signal address : std_logic_vector(22 downto 0);
		signal readyStatus : ReadyStatus_t;
		-- Not for connection
		signal state : std_logic_vector(2 downto 0);
		signal stateDbg : std_logic_vector(3 downto 0);
		signal olb : std_logic_vector(15 downto 0);
begin
	outputLight <= olb;
	--outputLight(15 downto 3) <= (others => '1');
	--outputLight(2 downto 0) <= state;
	--with state select outputLight <=
	--	(others => '1') when "10",
	--	(others => '0') when others;
		
	--successLight <= '1';
	flashROMModule_i : entity work.FlashRom
	port map (
		clock => clock,
		writeEnable => writeEnable,
		readEnable => readEnable,
		dataDisplay => dataDisplay,
		dataControl => dataControl,
		address => address,
		flashByte => flashByte,
		flashVPEN => flashVPEN,
		flashCE => flashCE,
		flashCE1 => flashCE1,
		flashCE2 => flashCE2,
		flashOE => flashOE,
		flashWE => flashWE,
		flashRP => flashRP,
		flashAddress => flashAddress,
		flashData => flashData,
		readyStatus => readyStatus,
		reset => reset,
		stateDbg => stateDbg
	);
	
	process(clock, reset)
	begin
		if reset = '0' then
			--outputLight <= (others => '0');
			state <= "000";
			olb <= (others => '0');
		elsif rising_edge(clock) then
			case state is
				-- write 0xABCD to flash[0]
				when "000" =>
					if readyStatus = STATUS_READY then
						writeEnable <= '0';
						readEnable <= '1';
						address <= (others => '0');
						dataControl <= "0101101000111100";
					else
						writeEnable <= '1';
						readEnable <= '1';
						state <= "110";
					end if;
				when "110" =>
					state <= "111";
				when "111" =>
					state <= "100";
				when "100" =>
					if readyStatus = STATUS_READY then
						state <= "001";
					end if;
				when "011" =>
					if readyStatus = STATUS_READY then
						writeEnable <= '0';
						readEnable <= '1';
						address <= (1 => '1', others => '0');
						dataControl <= X"ED34";
					else
						writeEnable <= '1';
						readEnable <= '1';
						state <= "010";
					end if;
				-- read flash[0] and examine
				when "001" =>
					if readyStatus = STATUS_READY then
						writeEnable <= '1';
						readEnable <= '0';
						address <= "00000000000000000000000";
						state <= "101";
					end if;
				when "101" =>
					if readyStatus = STATUS_READY then
						state <= "010";
					end if;
				when "010" =>
					if readyStatus = STATUS_READY then
						if olb = "0000000000000000" then
							olb <= dataDisplay;
						end if;
						if dataDisplay = X"ABCD" then
							successLight <= '1';
						else
							successLight <= '0';
						end if;
						--state <= "11";
					else
						writeEnable <= '1';
						readEnable <= '1';
					end if;
				when others =>
			end case;
			
			
		end if;
	end process;
end architecture;
