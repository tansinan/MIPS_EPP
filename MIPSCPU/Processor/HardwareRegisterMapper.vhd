library ieee;
use ieee.std_logic_1164.all;
use work.HardwareController.all;
use work.MIPSCPU.all;
use work.MIPSCP0.all;

entity HardwareAddressMapper is
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
		secondaryRAMResult : in PhysicsRAMData_t;
		uart1Control : out HardwareRegisterControl_t;
		uart1Result : in CPUData_t
	);
	type AddressType_t is
	(
		USER_SPACE_ADDRESS,
		KERNEL_SPACE_ADDRESS,
		ISA_ADDRESS,
		UNKNOWN
	);
end entity;

architecture Behavioral of HardwareAddressMapper is
	signal addressType : AddressType_t;
	signal savedAddressType : AddressType_t;
	signal savedAddressType2 : AddressType_t;
	signal usedRAMControl : RAMControl_t;
begin
	-- Determine the actual used RAM Control signal
	-- TODO: add simulation debugging statement to check RAM access violation.
	process(ramControl1, ramControl2, ramControl3)
	begin
		if ramControl3.readEnabled = FUNC_ENABLED or 
		ramControl3.writeEnabled = FUNC_ENABLED then
			usedRAMControl <= ramControl3;
		elsif ramControl2.readEnabled = FUNC_ENABLED or 
		ramControl2.writeEnabled = FUNC_ENABLED then
			usedRAMControl <= ramControl2;
		else
			usedRAMControl <= ramControl1;
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
	process(addressType, usedRAMControl)
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
			when ISA_ADDRESS =>
				if usedRAMControl.readEnabled = FUNC_ENABLED then
					uart1Control.operation <= REGISTER_OPERATION_READ;
				elsif usedRAMControl.writeEnabled = FUNC_ENABLED then
					uart1Control.operation <= REGISTER_OPERATION_WRITE;
				end if;
				uart1Control.address <= usedRAMControl.address;
				uart1Control.data <= usedRAMControl.data;
			when others =>
				primaryRAMHardwareControl.readEnabled <= FUNC_DISABLED;
				primaryRAMHardwareControl.writeEnabled <= FUNC_DISABLED;
				secondaryRAMHardwareControl.readEnabled <= FUNC_DISABLED;
				secondaryRAMHardwareControl.writeEnabled <= FUNC_DISABLED;
				uart1Control.address <= (others => '0');
		end case;
	end process;
		
	process(clock,reset)
	begin
		if rising_edge(clock) then
			savedAddressType <= addressType;
			savedAddressType2 <= savedAddressType;
		end if;
	end process;
	
	-- Determine the result
	process(savedAddressType, primaryRAMResult, secondaryRAMResult, uart1Result)
	begin
		case savedAddressType is
			when USER_SPACE_ADDRESS =>
				result <= secondaryRAMResult;
			when KERNEL_SPACE_ADDRESS =>
				result <= primaryRAMResult;
			when ISA_ADDRESS =>
				result <= uart1Result;
			when others =>
				result <= (others => '0');
		end case;
	end process;

end architecture;

