library ieee;
use ieee.std_logic_1164.all;
use work.MIPSCPU.all;
use work.MIPSCP0.all;

entity Coprocessor0_e is
	port (
		reset : in Reset_t;
		clock : in Clock_t;
		instruction : in Instruction_t;
		instructionExecutionEnabled : in EnablingControl_t;
		primaryRegisterFileData : in mips_register_file_port;
		primaryRegisterFileControl : out RegisterFileControl_t;
		debugCP0RegisterFileData : out CP0RegisterFileOutput_t
	);
end entity;

architecture Behavioral of Coprocessor0_e is
	signal cp0RegisterFileControl : CP0RegisterFileControl_t;
	signal cp0RegisterFileData : CP0RegisterFileOutput_t;
begin
	cp0PipelinePhaseInstructionDecode_i: entity work.CP0PipelinePhaseInstructionDecode
	port map
	(
		reset => reset,
		clock => clock,
		instruction => instruction,
		instructionExecutionEnabled => instructionExecutionEnabled,
		primaryRegisterFileData => primaryRegisterFileData,
		primaryRegisterFileControl => primaryRegisterFileControl,
		cp0RegisterFileData => cp0RegisterFileData,
		cp0RegisterFileControl => cp0RegisterFileControl
	);
	
	cp0RegisterFile_i: entity work.CP0RegisterFile_c
    port map
	(
		reset => reset,
		clock => clock,
        control => cp0RegisterFileControl,
		output => cp0RegisterFileData
	);

end architecture;

