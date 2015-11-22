library ieee;
use ieee.std_logic_1164.all;
use work.MIPSCPU.all;

entity RAMController is
	port (
		clock : in std_logic;
		reset : in std_logic;
		readControl1 : in RAMReadControl_t;
		readControl2 : in RAMReadControl_t;
		writeControl : in RAMWriteControl_t;
		result : out std_logic_vector(PHYSICS_RAM_DATA_WIDTH - 1 downto 0);
		phyRAMEnable : out std_logic;
		phyRAMWriteEnable : out std_logic;
		phyRAMReadEnable : out std_logic;
		phyAddressBus : out std_logic_vector(PHYSICS_RAM_ADDRESS_WIDTH - 1 downto 0);
		phyDataBus : inout std_logic_vector(PHYSICS_RAM_DATA_WIDTH - 1 downto 0)
	);
end entity;

architecture Behavioral of RAMController is
begin
	result <= phyDataBus;
	phyRAMEnable <= '0';
	process(clock, reset)
	begin
		if readControl1.enable = '0' then
			phyRAMWriteEnable <= '1';
			phyRAMReadEnable <= '0';
			phyAddressBus <= readControl1.address;
		elsif readControl2.enable = '0' then
			phyRAMWriteEnable <= '1';
			phyRAMReadEnable <= '0';
			phyAddressBus <= readControl2.address;
		elsif writeControl.enable = '0' then
			phyRAMWriteEnable <= '0';
			phyRAMReadEnable <= '1';
			phyAddressBus <= writeControl.address;
		else
			phyRAMWriteEnable <= '0';
			phyRAMReadEnable <= '0';
			phyAddressBus <= (others => '0');
		end if;
	end process;
end architecture;

