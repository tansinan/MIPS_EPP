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
        -- Connecct with flash ROM
        flashByte: out std_logic;
        flashVPEN: out std_logic;
        flashCE, flashOE, flashWE: out std_logic;
        flashRP: out std_logic;
        flashAddress: out std_logic_vector(22 downto 0);
        flashData: inout std_logic_vector(15 downto 0)
    );
end entity;

architecture Behavioral of FlashROMDemo is
    -- Connect with other CPU Parts
    signal writeEnable: std_logic;
    signal readEnable: std_logic;
    signal dataDisplay: std_logic_vector(15 downto 0);
    signal dataControl: std_logic_vector(15 downto 0);
    signal address: std_logic_vector(22 downto 0);
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
		flashData => flashData
	);
    process(clock, reset)
    begin
    end process;
end architecture;
