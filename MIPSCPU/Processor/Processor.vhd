library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.MIPSCPU.all;
use work.MIPSCP0.all;
use work.HardwareController.all;

entity Processor is
	port (
		reset : in Reset_t;
		clock : in Clock_t;
		clock50M : in Clock_t;
		debugData : out CPUDebugData_t;
		primaryRAMControl : out HardwareRAMControl_t;
		primaryRAMResult : in RAMData_t;
		secondaryRAMControl : out HardwareRAMControl_t;
		secondaryRAMResult : in RAMData_t;
		uart1Control : out HardwareRegisterControl_t;
		light : out std_logic_vector(15 downto 0);
		uart1Result : in CPUData_t;
		cp0ExternalInterruptSource : in CP0ExternalInterruptSource_t
	);
end entity;

architecture Behavioral of Processor is
	signal register_file_input: std_logic_vector (MIPS_CPU_DATA_WIDTH - 1 downto 0);
	signal register_file_operation: std_logic_vector (MIPS_CPU_REGISTER_COUNT - 1 downto 0);
	signal register_file_output : mips_register_file_port;
	signal registerFileControl1 : RegisterFileControl_t;
	signal cp0PipelineRegisterFileControl : RegisterFileControl_t;
	signal highLatencyMatheRegisterFileControl : RegisterFileControl_t;

	signal pipelinePhaseIDEXInterface : PipelinePhaseIDEXInterface_t;
	signal pipelinePhaseEXMAInterface : PipelinePhaseEXMAInterface_t;
	signal pipelinePhaseMAWBInterface : PipelinePhaseMAWBInterface_t;

	signal pipelinePhaseIFIDException : CP0ExceptionTrigger_t;
	signal pipelinePhaseIDEXException : CP0ExceptionTrigger_t;
	signal pipelinePhaseEXMAException : CP0ExceptionTrigger_t;

	signal instructionToCP0 : Instruction_t;
	signal instructionToPrimary : Instruction_t;
	signal instructionExecutionEnabledCP0 : EnablingControl_t;
	signal instructionToHighLatencyMath : Instruction_t;
	signal instructionExecutionEnabledToHighLatencyMath : EnablingControl_t;
	
	signal instruction_done : std_logic;

	signal current_pipeline_phase : std_logic_vector(3 downto 0) := "0000";

	signal ramControl1 : RAMControl_t;
	signal ramControl2 : RAMControl_t;
	signal ramControl3 : RAMControl_t;
	signal memoryAccessResult : RAMData_t;
	signal memoryAccessExceptionTrigger : CP0ExceptionTrigger_t;

	signal pcControl1 : RegisterControl_t;
	signal pcControl2 : RegisterControl_t;
	signal pcControl3 : RegisterControl_t;
	signal pcValue : std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
	
	signal cp0ExceptionPCControl : RegisterControl_t;
	signal cp0PipelinePCControl : RegisterControl_t;
	signal cp0ExceptionPipelineClear : EnablingControl_t;
	signal cp0ExceptionTrigger : CP0ExceptionTrigger_t;
	signal cp0MemoryAccessExceptionTrigger : CP0ExceptionTrigger_t;
	
	signal cp0VirtualAddress : RAMAddress_t;
	signal cp0PhysicsAddress : RAMAddress_t;
begin
	--light <= register_file_output(3)(15 downto 0);
	light <= pcValue(15 downto 0);
	registerFile_i : entity work.RegisterFile port map (
		reset => reset,
		clock => clock,
		input => register_file_input,
		operation => register_file_operation,
		output => register_file_output
	);

	pcRegister_i : entity work.SpecialRegister port map (
		reset => reset,
		clock => clock,
		control0 => cp0ExceptionPCControl,
		control1 => cp0PipelinePCControl,
		control2 => pcControl1,
		control3 => pcControl2,
		control4 => pcControl3,
		output => pcValue
	);

	pipelinePhaseInstructionDecode_i: entity work.PipelinePhaseInstructionDecode port map (
		reset => reset,
		clock => clock,
		register_file => register_file_output,
		instruction => instructionToPrimary,
		phaseExCtrlOutput => pipelinePhaseIDEXInterface,
		pcValue => pcValue,
		pcControl => pcControl1,
		phaseIFExceptionTrigger => pipelinePhaseIFIDException,
		phaseEXExceptionTrigger => pipelinePhaseIDEXException,
		cp0ExceptionPipelineClear => cp0ExceptionPipelineClear
	);

	pipelinePhaseExecute_i: entity work.PipelinePhaseExecute
	port map (
		reset => reset,
		clock => clock,
		phaseIDInput => pipelinePhaseIDEXInterface,
		pcValue => pcValue,
		pcControl => pcControl3,
		ramControl => ramControl1,
		phaseMACtrlOutput => pipelinePhaseEXMAInterface,
		phaseIDExceptionTrigger => pipelinePhaseIDEXException,
		phaseMAExceptionTrigger => pipelinePhaseEXMAException,
		cp0ExceptionPipelineClear => cp0ExceptionPipelineClear
	);

	pipelinePhaseMemoryAccess_i: entity work.PipelinePhaseMemoryAccess
	port map (
		reset => reset,
		clock => clock,
		phaseEXInput => pipelinePhaseEXMAInterface,
		phaseWBCtrlOutput => pipelinePhaseMAWBInterface,
		exceptionTriggerOutput => cp0ExceptionTrigger,
		ramReadResult => memoryAccessResult,
		ramReadException => memoryAccessExceptionTrigger,
		phaseEXExceptionTrigger => pipelinePhaseEXMAException,
		cp0ExceptionPipelineClear => cp0ExceptionPipelineClear
	);

	pipelinePhaseWirteBack_i: entity work.PipelinePhaseWriteBack
	port map (
		ramControl => ramControl2,
		registerFileControl => registerFileControl1,
		phaseMAInput => pipelinePhaseMAWBInterface
	);
	
	registerFileWriter_i: entity work.RegisterFileWriter
	port map
	(
		control1 => registerFileControl1,
		control2 => cp0PipelineRegisterFileControl,
		control3 => highLatencyMatheRegisterFileControl,
		operation_output => register_file_operation,
		data_output => register_file_input
	);

	Coprocessor0_i : entity work.Coprocessor0_e
	port map
	(
		reset => reset,
		clock => clock,
		instruction => instructionToCP0,
		instructionExecutionEnabled => instructionExecutionEnabledCP0,
		primaryRegisterFileData => register_file_output,
		primaryRegisterFileControl => cp0PipelineRegisterFileControl,
		pcValue => pcValue,
		pcControlException => cp0ExceptionPCControl,
		pcControlPipeline => cp0PipelinePCControl,
		exceptionTrigger => cp0ExceptionTrigger,
		externalInterruptSource => cp0ExternalInterruptSource, 
		exceptionPipelineClear => cp0ExceptionPipelineClear,
		debugCP0RegisterFileData => open,
		virtualAddress => cp0VirtualAddress,
		physicsAddress => cp0PhysicsAddress,
		memoryTranslationExceptionTrigger => cp0MemoryAccessExceptionTrigger
	);
	
	hardwareAddressMapper : entity work.HardwareAddressMapper
	port map
	(
		clock => clock,
		reset => reset,
		ramControl1 => ramControl1,
		ramControl2 => ramControl2,
		ramControl3 => ramControl3,
		result => memoryAccessResult,
		primaryRAMHardwareControl => primaryRAMControl,
		primaryRAMResult => primaryRAMResult,
		secondaryRAMHardwareControl => secondaryRAMControl,
		secondaryRAMResult => secondaryRAMResult,
		uart1Control => uart1Control,
		uart1Result => uart1Result,
		cp0VirtualAddress => cp0VirtualAddress,
		cp0PhysicsAddress => cp0PhysicsAddress,
		cp0ExceptionTrigger => cp0MemoryAccessExceptionTrigger,
		exceptionTrigger => memoryAccessExceptionTrigger
	);
	
	-- Output internal debug data.
	debugData <= (
		pcValue => pcValue,
		primaryRegisterFile => register_file_output,
		currentInstruction => instructionToPrimary
	);

	Processor_Process : process (clock, reset)
	begin
		if reset = '0' then
			--instructionToPrimary <= MIPS_CPU_INSTRUCTION_NOP;
			--instructionExecutionEnabledCP0 <= FUNC_DISABLED;
			--ramControl3.address <= (others => '0');
			--ramControl3.writeEnabled <= FUNC_DISABLED;
			--ramControl3.readEnabled <= FUNC_ENABLED;
			--pcControl2.operation <= REGISTER_OPERATION_WRITE;
			--pcControl2.data <= x"80000000";
			current_pipeline_phase <= "1111";
		elsif rising_edge(clock) then
			if cp0exceptionPipelineClear = FUNC_ENABLED then
				current_pipeline_phase <= "0100";
			else
				if current_pipeline_phase = "1111" then
					current_pipeline_phase <= "0100";
				elsif current_pipeline_phase = "0000" then
					current_pipeline_phase <= current_pipeline_phase + 1;
				elsif current_pipeline_phase = "0100" then
					current_pipeline_phase <= "0000";
				else
					current_pipeline_phase <= current_pipeline_phase + 1;
				end if;
			end if;
		end if;
	end process;
	
	instructionFetchProcess : process (current_pipeline_phase, pcValue)
	begin
		pipelinePhaseIFIDException <= (
			enabled => FUNC_DISABLED,
			exceptionCode => (others => '0'),
			badVirtualAddress => (others => '0')
		);
		ramControl3.readOnStore <= FUNC_DISABLED;
		if  current_pipeline_phase = "0100" then
			pcControl2.operation <= REGISTER_OPERATION_WRITE;
			pcControl2.data <= pcValue + 4;
			ramControl3.address <= pcValue;
			ramControl3.writeEnabled <= FUNC_DISABLED;
			ramControl3.readEnabled <= FUNC_ENABLED;
			ramControl3.data <= (others => '0');
			if memoryAccessExceptionTrigger.enabled = FUNC_ENABLED then
				pipelinePhaseIFIDException <= memoryAccessExceptionTrigger;
				pipelinePhaseIFIDException.exceptionCode <=
					MIPS_CP0_CAUSE_EXCEPTION_CODE_ADDRESS_LOAD;
			end if;
		else
			if  current_pipeline_phase /= "1111" then
				pcControl2.operation <= REGISTER_OPERATION_READ;
			else
				pcControl2.operation <= REGISTER_OPERATION_WRITE;
				pcControl2.data <= x"bfc00000"; -- for FPGA Boot loader
				--pcControl2.data <= x"80000000"; -- for testbench
			end if;
			ramControl3.address <= (others => '0');
			ramControl3.writeEnabled <= FUNC_DISABLED;
			ramControl3.readEnabled <= FUNC_DISABLED;
			ramControl3.data <= (others => '0');
		end if;
	end process;
	
	process (current_pipeline_phase, memoryAccessResult)
		variable opcode : InstructionOpcode_t;
		variable funct : InstructionFunct_t;
		variable instruction : Instruction_t;
	begin
		if  current_pipeline_phase = "0000" then
			instruction := memoryAccessResult;
			opcode :=
				instruction(MIPS_CPU_INSTRUCTION_OPCODE_HI downto MIPS_CPU_INSTRUCTION_OPCODE_LO);
			funct := instruction(MIPS_CPU_INSTRUCTION_FUNCT_HI downto MIPS_CPU_INSTRUCTION_FUNCT_LO);
			if opcode = MIPS_CPU_INSTRUCTION_OPCODE_CP0 then
				instructionToPrimary <= MIPS_CPU_INSTRUCTION_NOP;
				instructionToCP0 <= instruction;
				instructionExecutionEnabledCP0 <= FUNC_ENABLED;
				instructionExecutionEnabledToHighLatencyMath <=
					FUNC_DISABLED;
			elsif opcode = MIPS_CPU_INSTRUCTION_OPCODE_SPECIAL
			and (funct = MIPS_CPU_INSTRUCTION_FUNCT_MFHI or
			funct = MIPS_CPU_INSTRUCTION_FUNCT_MFLO or
			funct = MIPS_CPU_INSTRUCTION_FUNCT_MTHI or
			funct = MIPS_CPU_INSTRUCTION_FUNCT_MTLO or
			funct = MIPS_CPU_INSTRUCTION_FUNCT_MULT or
			funct = MIPS_CPU_INSTRUCTION_FUNCT_MULTU) then
				instructionToPrimary <= MIPS_CPU_INSTRUCTION_NOP;
				instructionExecutionEnabledCP0 <= FUNC_DISABLED;
				instructionToHighLatencyMath <= instruction;
				instructionExecutionEnabledToHighLatencyMath <=
					FUNC_ENABLED;
			else
				instructionToPrimary <= instruction;
				instructionToCP0 <= MIPS_CPU_INSTRUCTION_NOP;
				instructionExecutionEnabledCP0 <= FUNC_DISABLED;
				instructionExecutionEnabledToHighLatencyMath <=
					FUNC_DISABLED;
			end if;
		else
			instructionToPrimary <= MIPS_CPU_INSTRUCTION_NOP;
			instructionExecutionEnabledCP0 <= FUNC_DISABLED;
		end if;
	end process;
	
	highLatencyMathModule_i : entity work.HighLatencyMathModule
	port map
	(
		reset => reset,
		clock => clock,
		clock50M => clock50M,
		instruction => instructionToHighLatencyMath,
		instructionExecutionEnabled =>
			instructionExecutionEnabledToHighLatencyMath,
		registerFileData => register_file_output,
		registerFileControl => highLatencyMatheRegisterFileControl
	);

end architecture;
