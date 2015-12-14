library ieee;
use ieee.std_logic_1164.all;
use work.MIPSCPU.all;

entity HighLatencyMathModule is
	port (
		reset : in Reset_t;
		clock : in Clock_t;
		instruction : in Instruction_t;
		instructionExecutionEnabled : in EnablingControl_t;
		registerFileData : in mips_register_file_port;
		registerFileControl : out RegisterFileControl_t;
		ready : out ReadyStatus_t
	);
end entity;

architecture Behavioral of HighLatencyMathModule is
	signal ipCoreWrapperNumber1 : CPUData_t;
	signal ipCoreWrapperNumber1Signed : EnablingControl_t;
	signal ipCoreWrapperNumber2 : CPUData_t;
	signal ipCoreWrapperNumber2Signed : EnablingControl_t;
	signal ipCoreWrapperResultReady : ReadyStatus_t;
	signal ipCoreWrapperOutput : CPUDoubleWordData_t;
	
	signal hiRegisterData : CPUData_t;
	signal hiRegisterControl : RegisterControl_t;
	signal loRegisterData : CPUData_t;
	signal loRegisterControl : RegisterControl_t;
begin
	highLatencyMathIPCoreWrapper_i : entity work.HighLatencyMathIPCoreWrapper
	port map
	(
		clock => clock,
		reset => reset,
		number1 => ipCoreWrapperNumber1,
		number1Signed => ipCoreWrapperNumber1Signed,
		number2 => ipCoreWrapperNumber2,
		number2Signed => ipCoreWrapperNumber2Signed,
		resultReady => ipCoreWrapperResultReady,
		output => ipCoreWrapperOutput
	);
	
	hiRegister_i : entity work.SingleRegister
	port map
	(
		reset => reset,
		clock => clock,
		operation => hiRegisterControl.operation,
		input => hiRegisterControl.data,
		output => hiRegisterData
	);
	
	loRegister_i : entity work.SingleRegister
	port map
	(
		reset => reset,
		clock => clock,
		operation => loRegisterControl.operation,
		input => loRegisterControl.data,
		output => loRegisterData
	);
	
	highLatencyMathInstructionDecode_i : entity work.HighLatencyMathInstructionDecode
	port map
	(
		reset => reset,
		clock => clock,
		instruction => instruction,
		instructionExecutionEnabled => instructionExecutionEnabled,
		registerFileData => registerFileData,
		registerFileControl => registerFileControl,
		hiRegisterData => hiRegisterData,
		hiRegisterControl => hiRegisterControl,
		loRegisterData => loRegisterData,
		loRegisterControl => loRegisterControl,
		ready => ready
	);
end architecture;