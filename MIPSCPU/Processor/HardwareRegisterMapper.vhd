library ieee;
use ieee.std_logic_1164.all;

entity HardwareRegisterMapper is
	port
	(
		clock : in std_logic;
		reset : in std_logic;
		readControl1 : in RAMReadControl_t;
		readControl2 : in RAMReadControl_t;
		writeControl : in RAMWriteControl_t;
		physicalAddress : in CPUData_t;
		result : out std_logic_vector(PHYSICS_RAM_DATA_WIDTH - 1 downto 0)
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
begin
	-- Determine the address type;
	process(physicalAddress)
	begin
		if physicalAddress and ISA_ADDRESS_SPACE_MASK = ISA_ADDRESS_SPACE then
			addressType <= ISA_ADDRESS;
		elsif physicalAddress and KERNEL_ADDRESS_SPACE_MASK = KERNEL_ADDRESS_SPACE then
			addressType <= KERNEL_SPACE_ADDRESS;
		elsif physicalAddress and USER_ADDRESS_SPACE_MASK = USER_ADDRESS_SPACE then
			addressType <= USER_SPACE_ADDRESS;
		else
			addressType <= ISA_ADDRESS;
		end if;
	end process;
	
	-- According to the address type, determine control signals
	process(addressType)
	begin
	end process;

end architecture;

