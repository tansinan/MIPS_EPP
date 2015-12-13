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
		flashRP : out std_logic;
		flashAddress : out std_logic_vector(22 downto 0);
		flashData : inout std_logic_vector(15 downto 0)
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
		signal state : std_logic_vector(1 downto 0);
begin
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
		flashOE => flashOE,
		flashWE => flashWE,
		flashRP => flashRP,
		flashAddress => flashAddress,
		flashData => flashData,
		readyStatus => readyStatus,
		reset => reset
	);
	
	process(clock, reset)
	begin
		if reset = '0' then
			state <= "00";
		elsif rising_edge(clock) then
			case state is
				-- write 0xABCD to flash[0]
				when "00" =>
					if readyStatus = STATUS_READY then
						writeEnable <= '0';
						readEnable <= '1';
						address <= (others => '0');
						dataControl <= X"ABCD";
					else
						writeEnable <= '1';
						readEnable <= '1';
						state <= "01";
					end if;
				-- read flash[0] and examine
				when "01" =>
					if readyStatus = STATUS_READY then
						writeEnable <= '1';
						readEnable <= '0';
						address <= (others => '0');
						state <= "10";
					end if;
				when "10" =>
					if readyStatus = STATUS_READY then
						if dataDisplay = X"ABCD" then
							successLight <= '1';
						else
							successLight <= '0';
						end if;
						state <= "11";
					else
						writeEnable <= '1';
						readEnable <= '1';
					end if;
				when others =>
			end case;
			
			
		end if;
	end process;
end architecture;
