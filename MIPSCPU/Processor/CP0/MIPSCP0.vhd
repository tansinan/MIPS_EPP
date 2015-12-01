library ieee;
use ieee.std_logic_1164.all;
use work.MIPSCPU.all;

package MIPSCP0 is

	-- Constants and (sub)types related to the CP0 register file
	-- The address width of the registers in CP0
	constant MIPS_CP0_REGISTER_ADDRESS_WIDTH: integer := 5;

	-- The number of registers in CP0
	constant MIPS_CP0_REGISTER_COUNT: integer := 2**MIPS_CPU_REGISTER_ADDRESS_WIDTH;
	subtype CP0RegisterAddress_t is
		std_logic_vector(MIPS_CP0_REGISTER_COUNT - 1 downto 0);

	type CP0RegisterFileOutput_t is
		array(0 to MIPS_CP0_REGISTER_COUNT - 1) of CPUData_t;

	type CP0RegisterFileControl_t is
		array(0 to MIPS_CP0_REGISTER_COUNT - 1) of RegisterControl_t;

	constant MIPS_CP0_TLB_INDEX_WIDTH : integer := 4;
	constant MIPS_CP0_TLB_ENTRY_COUNT : integer := 2**MIPS_CP0_TLB_INDEX_WIDTH;
	subtype CP0TLBEntryIndex_t is
		std_logic_vector(MIPS_CP0_TLB_INDEX_WIDTH - 1 downto 0);


	-- Constant and (sub)types related to CP0 TLB
	type CP0TLBEntry_t is
		record
			pageMask : CPUData_t;
			entryHigh : CPUData_t;
			entryLow0 : CPUData_t;
			entryLow1 : CPUData_t;
		end record;

	type CP0TLBOutput_t is
		array(0 to MIPS_CP0_TLB_ENTRY_COUNT - 1) of CP0TLBEntry_t;

	type CP0TLBControl_t is
		record
			data : CPUData_t;
			index : CP0TLBEntryIndex_t;
			writeEnabled : std_logic;
		end record;

end package;

package body MIPSCP0 is
end package body;