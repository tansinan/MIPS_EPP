library ieee;
use ieee.std_logic_1164.all;
use work.MIPSCPU.all;

package MIPSCP0 is
	-- The address width of the registers in primary processor
	constant MIPS_CP0_REGISTER_ADDRESS_WIDTH: integer := 5;

	-- The number of registers in primarty processor
	constant MIPS_CP0_REGISTER_COUNT: integer := 2**MIPS_CPU_REGISTER_ADDRESS_WIDTH;
	subtype CP0RegisterAddress_t is
		std_logic_vector(MIPS_CP0_REGISTER_COUNT - 1 downto 0);

	type CP0RegisterFileOutput_t is
		array(0 to MIPS_CP0_REGISTER_COUNT - 1) of CPUData_t;

	type CP0RegisterFileControl_t is
		array(0 to MIPS_CP0_REGISTER_COUNT - 1) of RegisterControl_t;

end package;

package body MIPSCP0 is
end package body;
