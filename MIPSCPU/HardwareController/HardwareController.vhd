library ieee;
use ieee.std_logic_1164.all;
--use work.MIPSCPU.all;

package HardwareController is
	--! Parameters related to physics RAM bus.
	constant PHYSICS_RAM_ADDRESS_WIDTH : integer := 20;
	constant PHYSICS_RAM_DATA_WIDTH : integer := 32;
	subtype PhysicsRAMData_t is std_logic_vector(PHYSICS_RAM_DATA_WIDTH - 1 downto 0);
	subtype PhysicsRAMAddress_t is std_logic_vector(PHYSICS_RAM_ADDRESS_WIDTH - 1 downto 0);
	type RAMControl_t is
		record
			writeEnabled : std_logic;
			readEnabled : std_logic;
			address : PhysicsRAMAddress_t;
			data : PhysicsRAMData_t;
		end record;
	type PhysicsRAMControl_t is
		record
			enabled : std_logic;
			writeEnabled : std_logic;
			readEnabled : std_logic;
		end record;
end package;

package body HardwareController is

end package body;
