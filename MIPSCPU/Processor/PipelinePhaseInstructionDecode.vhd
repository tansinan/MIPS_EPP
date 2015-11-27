library ieee;
use ieee.std_logic_1164.all;
use work.MIPSCPU.all;

entity PipelinePhaseInstructionDecode is
	port (
		reset : in std_logic;
		clock : in std_logic;
		register_file : in mips_register_file_port;
		instruction : in std_logic_vector(MIPS_CPU_INSTRUCTION_WIDTH - 1 downto 0);
		pcValue : in std_logic_vector (MIPS_CPU_DATA_WIDTH - 1 downto 0);
		pcControl : out RegisterControl_t;
		phaseExCtrlOutput : out PipelinePhaseIDEXInterface_t
	);
end PipelinePhaseInstructionDecode;

architecture Behavioral of PipelinePhaseInstructionDecode is
	component TypeIInstructionDecoder is
		port (
			instruction : in std_logic_vector(MIPS_CPU_INSTRUCTION_WIDTH - 1 downto 0);
			pcValue : in std_logic_vector (MIPS_CPU_DATA_WIDTH - 1 downto 0);
			registerFile : in mips_register_file_port;
			result : out InstructionDecodingResult_t
		);
	end component;
	component TypeRInstructionDecoder is
		port (
			instruction : in std_logic_vector(MIPS_CPU_INSTRUCTION_WIDTH - 1 downto 0);
			pcValue : in std_logic_vector (MIPS_CPU_DATA_WIDTH - 1 downto 0);
			result : out InstructionDecodingResult_t
		);
	end component;
	component TypeJInstructionDecoder is
		port (
			instruction : in std_logic_vector(MIPS_CPU_INSTRUCTION_WIDTH - 1 downto 0);
			pcValue : in std_logic_vector (MIPS_CPU_DATA_WIDTH - 1 downto 0);
			result : out InstructionDecodingResult_t
		);
	end component;
	component RegisterFileReader is
		port (
			register_file_output : in mips_register_file_port;
			read_select_1 : in std_logic_vector (MIPS_CPU_REGISTER_ADDRESS_WIDTH - 1 downto 0);
			read_select_2 : in std_logic_vector (MIPS_CPU_REGISTER_ADDRESS_WIDTH - 1 downto 0);
			read_result_1 : out std_logic_vector (MIPS_CPU_DATA_WIDTH - 1 downto 0);
			read_result_2 : out std_logic_vector (MIPS_CPU_DATA_WIDTH - 1 downto 0)
		);
	end component;
	signal regData1 : std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
	signal regData2 : std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
	signal decodingResult : InstructionDecodingResult_t;
	signal decodingResultTypeI : InstructionDecodingResult_t;
	signal decodingResultTypeR : InstructionDecodingResult_t;
	signal decodingResultTypeJ : InstructionDecodingResult_t;
	signal opcode : std_logic_vector(MIPS_CPU_INSTRUCTION_OPCODE_WIDTH - 1 downto 0);
	signal phaseExCtrl : PipelinePhaseIDEXInterface_t;
begin
	opcode <= instruction (MIPS_CPU_INSTRUCTION_OPCODE_HI downto MIPS_CPU_INSTRUCTION_OPCODE_LO);
	phaseExCtrl.instructionOpcode <= opcode;

	decoder_I : TypeIInstructionDecoder port map (
		instruction => instruction,
		result => decodingResultTypeI,
		registerFile => register_file,
		pcValue => pcValue
	);

	decoder_R : TypeRInstructionDecoder port map (
		instruction => instruction,
		result => decodingResultTypeR,
		pcValue => pcValue
	);

	decoder_J : TypeJInstructionDecoder port map (
		instruction => instruction,
		result => decodingResultTypeJ,
		pcValue => pcValue
	);

	with opcode select decodingResult <=
		decodingResultTypeI when MIPS_CPU_INSTRUCTION_OPCODE_ADDIU,
		decodingResultTypeI when MIPS_CPU_INSTRUCTION_OPCODE_ANDI,
		decodingResultTypeI when MIPS_CPU_INSTRUCTION_OPCODE_ORI,
		decodingResultTypeI when MIPS_CPU_INSTRUCTION_OPCODE_XORI,
		decodingResultTypeI when MIPS_CPU_INSTRUCTION_OPCODE_LW,
		decodingResultTypeI when MIPS_CPU_INSTRUCTION_OPCODE_SW,
		decodingResultTypeI when MIPS_CPU_INSTRUCTION_OPCODE_BNE,
		decodingResultTypeI when MIPS_CPU_INSTRUCTION_OPCODE_BEQ,
		decodingResultTypeI when MIPS_CPU_INSTRUCTION_OPCODE_REGIMM,
		decodingResultTypeI when MIPS_CPU_INSTRUCTION_OPCODE_BGTZ,
		decodingResultTypeI when MIPS_CPU_INSTRUCTION_OPCODE_BLEZ,
		decodingResultTypeR when MIPS_CPU_INSTRUCTION_OPCODE_SPECIAL,
		decodingResultTypeJ when MIPS_CPU_INSTRUCTION_OPCODE_J;

	pcControl <= decodingResult.pcControl;
	--TODO I think this is ugly, need to be changed later.
	with opcode select phaseExCtrl.targetIsRAM <=
		FUNC_ENABLED when MIPS_CPU_INSTRUCTION_OPCODE_SW,
		FUNC_DISABLED when others;

	register_file_reader : RegisterFileReader port map (
		register_file_output => register_file,
		read_select_1 => decodingResult.regAddr1,
		read_result_1 => regData1,
		read_select_2 => decodingResult.regAddr2,
		read_result_2 => regData2
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
			phaseExCtrlOutput <= phaseExCtrl;
		end if;
	end process;
end Behavioral;
