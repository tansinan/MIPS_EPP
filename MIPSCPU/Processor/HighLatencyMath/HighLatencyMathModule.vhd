library ieee;
use ieee.std_logic_1164.all;
use work.MIPSCPU.all;

entity HighLatencyMathModule is
	port (
		reset : in Reset_t;
		clock : in Clock_t;
		clock50M : in Clock_t;
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
	signal ipCoreWrapperIsMultiplication : EnablingControl_t;
	signal ipCoreWrapperIsDivision : EnablingControl_t;

	signal hiRegisterData : CPUData_t;
	signal hiRegisterControl : RegisterControl_t;
	signal loRegisterData : CPUData_t;
	signal loRegisterControl : RegisterControl_t;
begin
	highLatencyMathIPCoreWrapper_i : entity work.HighLatencyMathIPCoreWrapper
	port map
	(
		clock => clock,
		clock50M => clock50M,
		reset => reset,
		number1 => ipCoreWrapperNumber1,
		number1Signed => ipCoreWrapperNumber1Signed,
		number2 => ipCoreWrapperNumber2,
		number2Signed => ipCoreWrapperNumber2Signed,
		resultReady => ipCoreWrapperResultReady,
		output => ipCoreWrapperOutput,
		isMultiplication => ipCoreWrapperIsMultiplication,
		isDivision => ipCoreWrapperIsDivision
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
		ipCoreWrapperNumber1 => ipCoreWrapperNumber1,
		ipCoreWrapperNumber1Signed => ipCoreWrapperNumber1Signed,
		ipCoreWrapperNumber2 => ipCoreWrapperNumber2,
		ipCoreWrapperNumber2Signed => ipCoreWrapperNumber2Signed,
		ipCoreWrapperResultReady => ipCoreWrapperResultReady,
		ipCoreWrapperOutput => ipCoreWrapperOutput,
		ready => ready
	);
end architecture;
