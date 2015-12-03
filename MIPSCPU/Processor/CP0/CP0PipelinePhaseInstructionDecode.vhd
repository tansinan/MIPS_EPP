library ieee;
use ieee.std_logic_1164.all;

entity CP0PipelinePhaseInstructionDecode is
	port (
		reset : in std_logic;
		clock : in std_logic;
		instruction : in Instruction_t;
		primaryRegisterFile : in mips_register_file_port;
		cp0RegisterFile : in CP0RegisterFileOutput_t;
		pcValue : in CPUData_t
	);
end entity;

architecture Behavioral of CP0PipelinePhaseInstructionDecode is
begin
end architecture;
