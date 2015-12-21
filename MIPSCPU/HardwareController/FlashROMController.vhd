library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.MIPSCPU.all;
use work.HardwareController.all;

entity FlashRomController is
	port (
		clock: in Clock_t;
		reset: in Reset_t;
		control : in HardwareRegisterControl_t;
		output : out CPUData_t;
		-- Connect with Flash ROM
		flashByte : out std_logic;
		flashVPEN : out std_logic;
		flashCE, flashOE, flashWE : out std_logic;
		flashRP : out std_logic;
		flashAddress : out std_logic_vector(22 downto 0);
		flashData : inout std_logic_vector(15 downto 0)
	);
end entity;

architecture Behavioral of FlashRomController is
	-- Connect with FlashRomModule
	signal dataDisplay : std_logic_vector(15 downto 0);
	signal dataControl : std_logic_vector(15 downto 0);
	signal address : std_logic_vector(22 downto 0);
	signal readyStatus : ReadyStatus_t;
	-- Not for connection
	signal stateDbg : std_logic_vector(3 downto 0);
begin
	flashROMModule_i : entity work.FlashRom
	port map (
		clock => clock,
		writeEnable => writeEnable,
		readEnable => readEnable,
		eraseEnable => eraseEnable,
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
		reset => reset,
		stateDbg => stateDbg
	);
	
	readEnable <= control.data(31);
	writeEnable <= control.data(30);
	eraseEnable <= control.data(29);
	output <= readyStatus & "000000000000000" & dataDisplay;
	dataControl <= control.data(15 downto 0);
	address <= control.address(22 downto 0);
	
end architecture;
