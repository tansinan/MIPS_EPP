library ieee;
use ieee.std_logic_1164.all;
--use work.MIPSCPU.all;

package HardwareController is
	--! Parameters related to physics RAM bus.
	constant PHYSICS_RAM_ADDRESS_WIDTH : integer := 20;
	constant PHYSICS_RAM_DATA_WIDTH : integer := 32;
	subtype PhysicsRAMData_t is std_logic_vector(PHYSICS_RAM_DATA_WIDTH - 1 downto 0);
	subtype PhysicsRAMAddress_t is std_logic_vector(PHYSICS_RAM_ADDRESS_WIDTH - 1 downto 0);
	type HardwareRAMControl_t is
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
		
	-- Constants and (sub)types related to ISA registers.
	constant ISA_REGISTER_EFFECTIVE_WIDTH : integer := 12;
	subtype ISAHardwareRegisterAddress_t is
		std_logic_vector(ISA_REGISTER_EFFECTIVE_WIDTH - 1 downto 0);
	constant UART1_REGISTER_DATA : ISAHardwareRegisterAddress_t := x"3F8";
	constant UART1_REGISTER_STATUS : ISAHardwareRegisterAddress_t := x"40C";
	constant UART1_REGISTER_STATUS_BIT_CAN_READ : integer := 0;
	constant UART1_REGISTER_STATUS_BIT_CAN_WRITE : integer := 5;
	
end package;

package body HardwareController is

end package body;
