library ieee;
use ieee.std_logic_1164.all;
use work.MIPSCPU.all;
use work.MIPSCP0.all;

entity PipelinePhaseInstructionDecode is
	port (
		reset : in std_logic;
		clock : in std_logic;
		register_file : in mips_register_file_port;
		instruction : in Instruction_t;
		pcValue : in CPUData_t;
		pcControl : out RegisterControl_t;
		phaseExCtrlOutput : out PipelinePhaseIDEXInterface_t;
		phaseIFExceptionTrigger : in CP0ExceptionTrigger_t;
		phaseEXExceptionTrigger : out CP0ExceptionTrigger_t;
		cp0ExceptionPipelineClear : in EnablingControl_t
	);
end PipelinePhaseInstructionDecode;

architecture Behavioral of PipelinePhaseInstructionDecode is
	signal regData1 : std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
	signal regData2 : std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
	signal decodingResult : InstructionDecodingResult_t;
	signal decodingResultTypeI : InstructionDecodingResult_t;
	signal decodingResultTypeR : InstructionDecodingResult_t;
	signal decodingResultTypeJ : InstructionDecodingResult_t;
	signal opcode : InstructionOpcode_t;
	signal funct : InstructionFunct_t;
	signal phaseExCtrl : PipelinePhaseIDEXInterface_t;
	signal phaseExExceptionTriggerCtrl : CP0ExceptionTrigger_t;
begin
	-- Extract opcode and funct from the instruction.
	process(instruction)
	begin
		opcode <= instruction (MIPS_CPU_INSTRUCTION_OPCODE_HI downto MIPS_CPU_INSTRUCTION_OPCODE_LO);
		funct <= instruction (MIPS_CPU_INSTRUCTION_FUNCT_HI downto MIPS_CPU_INSTRUCTION_FUNCT_LO);
	end process;
	phaseExCtrl.instructionOpcode <= opcode;

	decoder_I : entity work.TypeIInstructionDecoder
	port map
	(
		instruction => instruction,
		result => decodingResultTypeI,
		registerFile => register_file,
		pcValue => pcValue
	);

	decoder_R : entity work.TypeRInstructionDecoder
	port map
	(
		instruction => instruction,
		result => decodingResultTypeR,
		registerFile => register_file,
		pcValue => pcValue
	);

	decoder_J : entity work.TypeJInstructionDecoder
	port map
	(
		instruction => instruction,
		result => decodingResultTypeJ,
		registerFile => register_file,
		pcValue => pcValue
	);
	
	-- determine the decoding result, and whether to trigger an exception,
	-- according to the opcode, funct, and exception passed from IF.
	process(opcode, funct, phaseIFExceptionTrigger,
	decodingResultTypeI, decodingResultTypeR, decodingResultTypeJ)
	begin
		decodingResult <= INSTRUCTION_DECODING_RESULT_CLEAR;
		phaseExExceptionTriggerCtrl <= MIPS_CP0_EXCEPTION_TRIGGER_CLEAR;
		if phaseIFExceptionTrigger.enabled = FUNC_ENABLED then
			phaseExExceptionTriggerCtrl <= phaseIFExceptionTrigger;
		elsif opcode = MIPS_CPU_INSTRUCTION_OPCODE_SPECIAL and 
		funct = MIPS_CPU_INSTRUCTION_FUNCT_SYSCALL then
			phaseExExceptionTriggerCtrl <= (
				enabled => FUNC_ENABLED,
				exceptionCode => MIPS_CP0_CAUSE_EXCEPTION_CODE_SYSCALL,
				badVirtualAddress => (others => '0')
			);
		elsif opcode = MIPS_CPU_INSTRUCTION_OPCODE_SLTI or
		opcode = MIPS_CPU_INSTRUCTION_OPCODE_SLTIU then
			decodingResult <= decodingResultTypeI;
		else
			case opcode is
				when MIPS_CPU_INSTRUCTION_OPCODE_ADDIU |
				MIPS_CPU_INSTRUCTION_OPCODE_ANDI | 
				MIPS_CPU_INSTRUCTION_OPCODE_ORI |
				MIPS_CPU_INSTRUCTION_OPCODE_XORI |
				MIPS_CPU_INSTRUCTION_OPCODE_LW |
				MIPS_CPU_INSTRUCTION_OPCODE_LH |
				MIPS_CPU_INSTRUCTION_OPCODE_LHU |
				MIPS_CPU_INSTRUCTION_OPCODE_LB |
				MIPS_CPU_INSTRUCTION_OPCODE_LBU |
				MIPS_CPU_INSTRUCTION_OPCODE_SW |
				MIPS_CPU_INSTRUCTION_OPCODE_SH |
				MIPS_CPU_INSTRUCTION_OPCODE_SB |
				MIPS_CPU_INSTRUCTION_OPCODE_BNE |
				MIPS_CPU_INSTRUCTION_OPCODE_BEQ |
				MIPS_CPU_INSTRUCTION_OPCODE_REGIMM |
				MIPS_CPU_INSTRUCTION_OPCODE_BGTZ |
				MIPS_CPU_INSTRUCTION_OPCODE_BLEZ |
				MIPS_CPU_INSTRUCTION_OPCODE_LWL |
				MIPS_CPU_INSTRUCTION_OPCODE_LWR |
				MIPS_CPU_INSTRUCTION_OPCODE_LUI =>
					decodingResult <= decodingResultTypeI;
				when MIPS_CPU_INSTRUCTION_OPCODE_SPECIAL =>
					decodingResult <= decodingResultTypeR;
				when MIPS_CPU_INSTRUCTION_OPCODE_J |
				MIPS_CPU_INSTRUCTION_OPCODE_JAL =>
					decodingResult <= decodingResultTypeJ;
				when others =>
					phaseExExceptionTriggerCtrl <= (
						enabled => FUNC_ENABLED,
						exceptionCode => MIPS_CP0_CAUSE_EXCEPTION_CODE_RESERVED_INSTRUCTION,
						badVirtualAddress => (others => '0')
					);
			end case;
		end if;
	end process;

	pcControl <= decodingResult.pcControl;
	--TODO I think this is ugly, need to be changed later.
	with opcode select phaseExCtrl.targetIsRAM <=
		FUNC_ENABLED when MIPS_CPU_INSTRUCTION_OPCODE_SW,
		FUNC_ENABLED when MIPS_CPU_INSTRUCTION_OPCODE_SB,
		FUNC_ENABLED when MIPS_CPU_INSTRUCTION_OPCODE_SH,
		FUNC_DISABLED when others;

	registerFileReader1_e : entity work.RegisterFileReader port map (
		register_file_output => register_file,
		readSelect => decodingResult.regAddr1,
		readResult => regData1
	);
	registerFileReader2_e : entity work.RegisterFileReader port map (
		register_file_output => register_file,
		readSelect => decodingResult.regAddr2,
		readResult => regData2
	);

	phaseExCtrl.operand1 <= regData1;
	with decodingResult.useImmOperand select phaseExCtrl.operand2 <=
		regData2 when '0',
		decodingResult.imm when '1',
		(others => 'X') when others;

	phaseExCtrl.operation <= decodingResult.operation;
	phaseExCtrl.targetReg <= decodingResult.regDest;
	phaseExCtrl.resultIsRAMAddr <= decodingResult.resultIsRAMAddr;
	phaseExCtrl.immIsPCValue <= decodingResult.immIsPCValue;
	with decodingResult.immIsPCValue select phaseExCtrl.extraImm <=
		regData2 when FUNC_DISABLED,
		decodingResult.imm when FUNC_ENABLED;

	PipelinePhaseInstructionDecode_Process : process (clock, reset)
	begin
		if reset = '0' then
			phaseExCtrlOutput.targetReg <= (others => '0');
			phaseExCtrlOutput.resultIsRAMAddr <= FUNC_DISABLED;
		elsif rising_edge(clock) then
			if cp0ExceptionPipelineClear = FUNC_ENABLED then
				phaseExCtrlOutput <= PIPELINE_PHASE_ID_EX_INTERFACE_CLEAR;
			else
				phaseExCtrlOutput <= phaseExCtrl;
				phaseExExceptionTrigger <= phaseExExceptionTriggerCtrl;
			end if;
		end if;
	end process;
end architecture;
