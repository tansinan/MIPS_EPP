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
		pcValue : in CPUData_t;
		exceptionPCValue : in CPUData_t;
		pcControlException : out RegisterControl_t;
		pcControlPipeline : out RegisterControl_t;
		exceptionTrigger : in CP0ExceptionTrigger_t;
		externalInterruptSource : in CP0ExternalInterruptSource_t;
		exceptionPipelineClear : out EnablingControl_t;
		debugCP0RegisterFileData : out CP0RegisterFileOutput_t;
		virtualAddress : in RAMAddress_t;
		physicsAddress : out RAMAddress_t;
		memoryTranslationExceptionTrigger : out CP0ExceptionTrigger_t;
		memoryTranslationOpcode : in InstructionOpcode_t
	);
end entity;

architecture Behavioral of Coprocessor0_e is
	signal cp0RegisterFileControl0 : CP0RegisterFileControl_t;
	signal cp0RegisterFileControl1 : CP0RegisterFileControl_t;
	signal cp0RegisterFileData : CP0RegisterFileOutput_t;
	signal cp0TLBControl : CP0TLBControl_t;
	signal cp0TLBData : CP0TLBData_t;
	signal internalInterruptSource : CP0InternalInterruptSource_t;
	signal timerInterruptCompareRegisterModifiedReset : EnablingControl_t;
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
		cp0RegisterFileControl => cp0RegisterFileControl0,
		cp0TLBData => cp0TLBData,
		cp0TLBControl => cp0TLBControl,
		pcControl => pcControlPipeline,
		compareRegisterModified => 
			timerInterruptCompareRegisterModifiedReset
	);
	
	cp0RegisterFile_i: entity work.CP0RegisterFile_c
    port map
	(
		reset => reset,
		clock => clock,
        control0 => cp0RegisterFileControl0,
		control1 => cp0RegisterFileControl1,
		output => cp0RegisterFileData
	);
	
	cp0TLB_i : entity work.CP0TLB_e
    port map (
		reset => reset,
		clock => clock,
		control => cp0TLBControl,
		output => cp0TLBData
	);
	
	cp0ExceptionHandler_i : entity work.CP0ExceptionHandler
	port map
	(
		clock => clock,
		reset => reset,
		exceptionTrigger => exceptionTrigger,
		externalInterruptSource => externalInterruptSource,
		internalInterruptSource => internalInterruptSource,
		pcValue => pcValue,
		exceptionPCValue => exceptionPCValue,
		pcOverrideControl => pcControlException,
		exceptionPipelineClear => exceptionPipelineClear,
		cp0RegisterFileData => cp0RegisterFileData,
		cp0RegisterFileControl => cp0RegisterFileControl1
	);
	
	cp0AddressTranslator_i : entity work.CP0AddressTranslator
	port map
	(
		tlbData => cp0TLBData,
		virtualAddress => virtualAddress,
		physicsAddress => physicsAddress,
		exceptionTriggerOut => memoryTranslationExceptionTrigger,
		instructionOpcode => memoryTranslationOpcode
	);
	
	CP0InternalTimerInterrupt_i : entity work.CP0InternalTimerInterrupt_e
	port map
	(
		clock => clock,
		reset => reset,
		cp0RegisterFileData => cp0RegisterFileData,
		interruptTriggerOutput => internalInterruptSource(0),
		compareRegisterModifiedReset => 
			timerInterruptCompareRegisterModifiedReset
	);

	-- TODO : Connect internal interrupt source to the timer interrupt trigger.
	--internalInterruptSource(0) <= (
	--	enabled => FUNC_DISABLED,
	--	interruptCodeMask => (others => '0')
	--);
end architecture;

