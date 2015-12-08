library ieee;
use ieee.std_logic_1164.all;
use work.HardwareController.all;
use work.MIPSCPU.all;
use work.MIPSCP0.all;

entity HardwareRegisterMapper is
	port
	(
		clock : in Clock_t;
		reset : in Reset_t;
		ramControl1 : in RAMControl_t;
		ramControl2 : in RAMControl_t;
		ramControl3 : in RAMControl_t;
		result : out RAMData_t;
		primaryRAMHardwareControl : out HardwareRAMControl_t;
		primaryRAMResult : in PhysicsRAMData_t;
		secondaryRAMHardwareControl : out HardwareRAMControl_t;
		secondaryRAMResult : in PhysicsRAMData_t
	);
	type AddressType_t is
	(
		USER_SPACE_ADDRESS,
		KERNEL_SPACE_ADDRESS,
		ISA_ADDRESS,
		UNKNOWN
	);
end entity;

architecture Behavioral of HardwareRegisterMapper is
	signal addressType : AddressType_t;
	signal usedRAMControl : RAMControl_t;
begin
	-- Determine the actual used RAM Control signal
	-- TODO: add simulation debugging statement to check RAM access violation.
	process(ramControl1, ramControl2, ramControl3)
	begin
		if ramControl1.readEnabled = FUNC_ENABLED or 
		ramControl1.writeEnabled = FUNC_ENABLED then
			usedRAMControl <= ramControl1;
		elsif ramControl2.readEnabled = FUNC_ENABLED or 
		ramControl2.writeEnabled = FUNC_ENABLED then
			usedRAMControl <= ramControl2;
		else
			usedRAMControl <= ramControl3;
		end if;
	end process;
	
	
	-- Determine the address type;
	process(usedRAMControl)
		variable physicsAddress : RAMAddress_t;
	begin
		physicsAddress := usedRAMControl.address;
		if (physicsAddress and ISA_ADDRESS_SPACE_MASK) = ISA_ADDRESS_SPACE then
			addressType <= ISA_ADDRESS;
		elsif (physicsAddress and KERNEL_ADDRESS_SPACE_MASK) = KERNEL_ADDRESS_SPACE then
			addressType <= KERNEL_SPACE_ADDRESS;
		elsif (physicsAddress and USER_ADDRESS_SPACE_MASK) = USER_ADDRESS_SPACE then
			addressType <= USER_SPACE_ADDRESS;
		else
			addressType <= UNKNOWN;
		end if;
	end process;
	
	-- According to the address type, determine control signals
	process(addressType)
	begin
		case addressType is
			when USER_SPACE_ADDRESS =>
				secondaryRAMHardwareControl <= (
					readEnabled => usedRAMControl.readEnabled,
					writeEnabled => usedRAMControl.writeEnabled,
					address => usedRAMControl.address(2 + PHYSICS_RAM_ADDRESS_WIDTH - 1 downto 2),
					data => usedRAMControl.data
				);
				primaryRAMHardwareControl.readEnabled <= FUNC_DISABLED;
				primaryRAMHardwareControl.writeEnabled <= FUNC_DISABLED;
			when KERNEL_SPACE_ADDRESS =>
				primaryRAMHardwareControl <= (
					readEnabled => usedRAMControl.readEnabled,
					writeEnabled => usedRAMControl.writeEnabled,
					address => usedRAMControl.address(2 + PHYSICS_RAM_ADDRESS_WIDTH - 1 downto 2),
					data => usedRAMControl.data
				);
				secondaryRAMHardwareControl.readEnabled <= FUNC_DISABLED;
				secondaryRAMHardwareControl.writeEnabled <= FUNC_DISABLED;
		end case;
	end process;

end architecture;

