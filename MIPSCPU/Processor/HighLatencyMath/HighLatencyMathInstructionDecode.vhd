library ieee;
use ieee.std_logic_1164.all;
use work.MIPSCPU.all;

entity HighLatencyMathInstructionDecode is
	port
	(
		reset : in Reset_t;
		clock : in Clock_t;
		instruction : in Instruction_t;
		instructionExecutionEnabled : in EnablingControl_t;
		registerFileData : in mips_register_file_port;
		registerFileControl : out RegisterFileControl_t;
		hiRegisterData : in CPUData_t;
		hiRegisterControl: out RegisterControl_t;
		loRegisterData : in CPUData_t;
		loRegisterControl: out RegisterControl_t
	);
end entity;

architecture Behavioral of HighLatencyMathInstructionDecode is
begin


end architecture;

