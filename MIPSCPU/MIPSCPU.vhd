library ieee;
use ieee.std_logic_1164.all;

package MIPSCPU is

	-- General numerical properties of the processor
	constant MIPS_CPU_DATA_WIDTH : integer := 32;
	constant MIPS_CPU_REGISTER_ADDRESS_WIDTH: integer := 5;
	constant MIPS_CPU_REGISTER_COUNT: integer := 2**MIPS_CPU_REGISTER_ADDRESS_WIDTH;
	
	-- General 
	constant ALU_OPERATION_CTRL_WIDTH : integer := 5;
	constant ALU_OPERATION_ADD : 
		std_logic_vector(ALU_OPERATION_CTRL_WIDTH - 1 downto 0) := "00000";
	constant ALU_OPERATION_SUBTRACT : 
		std_logic_vector(ALU_OPERATION_CTRL_WIDTH - 1 downto 0) := "00001";
	constant ALU_OPERATION_LOGIC_AND : 
		std_logic_vector(ALU_OPERATION_CTRL_WIDTH - 1 downto 0) := "00010";
	constant ALU_OPERATION_LOGIC_OR : 
		std_logic_vector(ALU_OPERATION_CTRL_WIDTH - 1 downto 0) := "00011";
	constant REGISTER_OPERATION_READ : std_logic := '0';
	constant REGISTER_OPERATION_WRITE : std_logic := '1';
	
	type mips_register_file_port is
		array(0 to MIPS_CPU_REGISTER_COUNT - 1) of std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
	
end MIPSCPU;


package body MIPSCPU is
end MIPSCPU;
