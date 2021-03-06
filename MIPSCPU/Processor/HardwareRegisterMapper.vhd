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
		uart1Result : in CPUData_t;
		flashROMControl : out HardwareRegisterControl_t;
		flashROMData : in CPUData_t;
		cp0VirtualAddress : out RAMAddress_t;
		cp0PhysicsAddress : in RAMAddress_t;
		cp0MemoryAccessOpcode : out InstructionOpcode_t;
		cp0ExceptionTrigger : in CP0ExceptionTrigger_t;
		exceptionTrigger : out CP0ExceptionTrigger_t
	);
	type AddressType_t is
	(
		USER_SPACE_ADDRESS,
		KERNEL_SPACE_ADDRESS,
		ISA_ADDRESS,
		BOOTLOADER_ADDRESS,
		FLASHROM_ADDRESS,
		UNKNOWN
	);
	type RAMSelect_t is
	(
		SELECT_PRIMARY_RAM,
		SELECT_SECONDARY_RAM
	);
end entity;

architecture Behavioral of HardwareAddressMapper is
	signal addressType : AddressType_t;
	signal savedAddressType : AddressType_t;
	signal savedReadOnStore : EnablingControl_t;
	signal usedRAMControl : RAMControl_t;
	signal savedROMData : CPUData_t;
	signal romData : CPUData_t;
	signal ramSelect : RAMSelect_t;
	signal savedRAMSelect : RAMSelect_t;
	signal cp0ExceptionTriggerRegister : CP0ExceptionTrigger_t;
	component ipcorebootloader
	port (
		a : in std_logic_vector(6 downto 0);
		spo : out std_logic_vector(31 downto 0)
	);
end component;
begin

	ipCoreBootloader_i : IPCoreBootloader
	port map (
		a => usedRAMControl.address(8 downto 2),
		spo => romData
	);

	-- Determine the actual used RAM Control signal
	-- TODO: add simulation debugging statement to check RAM access violation.
	process(ramControl1, ramControl2, ramControl3)
	begin
		usedRAMControl <= (
			readEnabled => FUNC_DISABLED,
			writeEnabled => FUNC_DISABLED,
			readOnStore => FUNC_DISABLED,
			address => x"80000000",
			data => (others => '0'),
			opcode => (others => '0')
		);
		if ramControl3.readEnabled = FUNC_ENABLED or 
		ramControl3.writeEnabled = FUNC_ENABLED then
			usedRAMControl <= ramControl3;
		elsif ramControl2.readEnabled = FUNC_ENABLED or 
		ramControl2.writeEnabled = FUNC_ENABLED then
			usedRAMControl <= ramControl2;
		elsif ramControl1.readEnabled = FUNC_ENABLED or 
		ramControl1.writeEnabled = FUNC_ENABLED then
			usedRAMControl <= ramControl1;
		end if;
	end process;
	
	process(usedRAMControl)
	begin
		cp0VirtualAddress <= usedRAMControl.address;
		cp0MemoryAccessOpcode <= usedRAMControl.opcode;
	end process;
	
	-- Determine the address type;
	process(cp0PhysicsAddress)
		variable physicsAddress : RAMAddress_t;
	begin
		physicsAddress := cp0PhysicsAddress;
		if (physicsAddress and ISA_ADDRESS_SPACE_MASK) = ISA_ADDRESS_SPACE then
			addressType <= ISA_ADDRESS;
		elsif (physicsAddress and KERNEL_ADDRESS_SPACE_MASK) = KERNEL_ADDRESS_SPACE then
			addressType <= KERNEL_SPACE_ADDRESS;
		elsif (physicsAddress and USER_ADDRESS_SPACE_MASK) = USER_ADDRESS_SPACE then
			addressType <= USER_SPACE_ADDRESS;
		elsif (physicsAddress and BOOTLOADER_ADDRESS_SPACE_MASK) = BOOTLOADER_ADDRESS_SPACE then
			addressType <= BOOTLOADER_ADDRESS;
		elsif (physicsAddress and FLASHROM_ADDRESS_SPACE_MASK) = FLASHROM_ADDRESS_SPACE then
			addressType <= FLASHROM_ADDRESS;
		else
			addressType <= UNKNOWN;
		end if;
	end process;
	
	-- According to the address type, determine control signals
	process(addressType, usedRAMControl, cp0PhysicsAddress)
	begin
		-- Default signals : disable everything.
		secondaryRAMHardwareControl <= (
			readEnabled => FUNC_DISABLED,
			writeEnabled => FUNC_DISABLED,
			address => (others => '0'),
			data => (others => '0')
		);
		primaryRAMHardwareControl <= (
			readEnabled => FUNC_DISABLED,
			writeEnabled => FUNC_DISABLED,
			address => (others => '0'),
			data => (others => '0')
		);
		uart1Control <= (
			operation => REGISTER_OPERATION_READ,
			address => (others => '0'),
			data => (others => '0')
		);
		flashROMControl <= (
			operation => REGISTER_OPERATION_READ,
			address => (others => '0'),
			data => (others => '0')
		);
		ramSelect <= SELECT_PRIMARY_RAM;
		case addressType is
			when USER_SPACE_ADDRESS | KERNEL_SPACE_ADDRESS =>
				if cp0PhysicsAddress(2 + PHYSICS_RAM_ADDRESS_WIDTH) = '0' then
					ramSelect <= SELECT_PRIMARY_RAM;
					primaryRAMHardwareControl <= (
						readEnabled => usedRAMControl.readEnabled,
						writeEnabled => usedRAMControl.writeEnabled,
						address => cp0PhysicsAddress(2 + PHYSICS_RAM_ADDRESS_WIDTH - 1 downto 2),
						data => usedRAMControl.data
					);
				else
					ramSelect <= SELECT_SECONDARY_RAM;
					secondaryRAMHardwareControl <= (
						readEnabled => usedRAMControl.readEnabled,
						writeEnabled => usedRAMControl.writeEnabled,
						address => cp0PhysicsAddress(2 + PHYSICS_RAM_ADDRESS_WIDTH - 1 downto 2),
						data => usedRAMControl.data
					);
				end if;
			when ISA_ADDRESS =>
				if usedRAMControl.readEnabled = FUNC_ENABLED then
					uart1Control.operation <= REGISTER_OPERATION_READ;
				elsif usedRAMControl.writeEnabled = FUNC_ENABLED then
					uart1Control.operation <= REGISTER_OPERATION_WRITE;
				end if;
				
				if usedRAMControl.readOnStore = FUNC_ENABLED and
				usedRAMControl.readEnabled = FUNC_ENABLED then
					uart1Control.address <= (others => '0');
				else
					uart1Control.address <= cp0PhysicsAddress;
				end if;
				uart1Control.data <= usedRAMControl.data;
			when FLASHROM_ADDRESS =>
				if usedRAMControl.readEnabled = FUNC_ENABLED then
					flashROMControl.operation <= REGISTER_OPERATION_READ;
				elsif usedRAMControl.writeEnabled = FUNC_ENABLED then
					flashROMControl.operation <= REGISTER_OPERATION_WRITE;
				end if;
				
				if usedRAMControl.readOnStore = FUNC_ENABLED and
				usedRAMControl.readEnabled = FUNC_ENABLED then
					flashROMControl.address <= (others => '0');
				else
					flashROMControl.address <= cp0PhysicsAddress;
				end if;
				flashROMControl.data <= usedRAMControl.data;
			when others =>
		end case;
	end process;
		
	process(clock,reset)
	begin
		if rising_edge(clock) then
			savedAddressType <= addressType;
			savedROMData <= romData;
			savedRAMSelect <= ramSelect;
			cp0ExceptionTriggerRegister <= cp0ExceptionTrigger;
			savedReadOnStore <= usedRAMControl.readOnStore;
		end if;
	end process;
	
	-- Determine the result
	process(savedAddressType, primaryRAMResult, secondaryRAMResult,
		uart1Result, savedRAMSelect)
	begin
		exceptionTrigger <= (
			enabled => FUNC_DISABLED,
			exceptionCode => (others => '0'),
			badVirtualAddress => (others => '0'),
			isTLBRefill => FUNC_DISABLED
		);
		result <= (others => '0');
		if cp0ExceptionTriggerRegister.enabled = FUNC_ENABLED then
			exceptionTrigger <= cp0ExceptionTriggerRegister;
		else
			case savedAddressType is
				when USER_SPACE_ADDRESS | KERNEL_SPACE_ADDRESS =>
					if savedRAMSelect = SELECT_PRIMARY_RAM then
						result <= primaryRAMResult;
					else
						result <= secondaryRAMResult;
					end if;
				when ISA_ADDRESS =>
					result <= uart1Result;
				when FLASHROM_ADDRESS =>
					result <= flashROMData;
				when BOOTLOADER_ADDRESS =>
					result <= savedROMData;
				when others =>
					exceptionTrigger <= (
						enabled => FUNC_ENABLED,
						exceptionCode => (others => 'U'), -- TODO needs to add correct excCode.
						badVirtualAddress => (others => '0'),
						isTLBRefill => FUNC_DISABLED
					);
					result <= (others => '0');
			end case;
		end if;
	end process;

end architecture;

