library ieee;
use ieee.std_logic_1164.all;
use work.MIPSCPU.all;

--TODO : This needs to be changed to a combo logic circuit.

entity RAMController_c is
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

architecture Behavioral of RAMController_c is
begin
	result <= phyDataBus;
	phyRAMEnable <= '0';
	process(clock, reset)
	begin	
		if rising_edge(clock) then
			if readControl1.enable = '0' then
				phyRAMWriteEnable <= '1';
				phyRAMReadEnable <= '0';
				phyAddressBus <= readControl1.address;
				phyDataBus <= (others => 'Z');
			elsif readControl2.enable = '0' then
				phyRAMWriteEnable <= '1';
				phyRAMReadEnable <= '0';
				phyAddressBus <= readControl2.address;
				phyDataBus <= (others => 'Z');
			elsif writeControl.enable = '0' then
				phyRAMWriteEnable <= '0';
				phyRAMReadEnable <= '1';
				phyAddressBus <= writeControl.address;
				phyDataBus <= writeControl.data;
			else
				phyRAMWriteEnable <= '0';
				phyRAMReadEnable <= '0';
				phyAddressBus <= (others => '0');
				phyDataBus <= (others => 'Z');
			end if;
		end if;
	end process;
end architecture;

