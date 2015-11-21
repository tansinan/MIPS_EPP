library ieee;
use ieee.std_logic_1164.all;
use work.MIPSCPU.all;

entity PipelinePhaseInstructionDecode is
	port (
		reset : in std_logic;
		clock : in std_logic;
		register_file : in mips_register_file_port;
		instruction : in std_logic_vector(MIPS_CPU_INSTRUCTION_WIDTH - 1 downto 0);
		alu_operand1_output : out std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
		alu_operand2_output : out std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
		alu_operation_output : out std_logic_vector(ALU_OPERATION_CTRL_WIDTH - 1 downto 0);
		register_destination_output : out std_logic_vector(MIPS_CPU_REGISTER_ADDRESS_WIDTH - 1 downto 0)
	);
end PipelinePhaseInstructionDecode;

architecture Behavioral of PipelinePhaseInstructionDecode is
	component TypeIInstructionDecoder is
		port (
			instruction : in std_logic_vector(MIPS_CPU_INSTRUCTION_WIDTH - 1 downto 0);
			result : out InstructionDecodingResult_t
		);
	end component;
	component TypeRInstructionDecoder is
		port (
			instruction : in std_logic_vector(MIPS_CPU_INSTRUCTION_WIDTH - 1 downto 0);
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
	signal alu_operand1 : std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
	signal alu_operand2 : std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
	signal alu_operation : std_logic_vector(ALU_OPERATION_CTRL_WIDTH - 1 downto 0);
	signal regData1 : std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
	signal regData2 : std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
	signal decodingResult : InstructionDecodingResult_t;
	signal decodingResultTypeI : InstructionDecodingResult_t;
	signal decodingResultTypeR : InstructionDecodingResult_t;
	signal opcode : std_logic_vector(MIPS_CPU_INSTRUCTION_OPCODE_WIDTH - 1 downto 0);
begin
	opcode <= instruction (MIPS_CPU_INSTRUCTION_OPCODE_HI downto MIPS_CPU_INSTRUCTION_OPCODE_LO);

	decoder_I : TypeIInstructionDecoder port map (
		instruction => instruction,
		result => decodingResultTypeI
	);

	decoder_R : TypeRInstructionDecoder port map (
		instruction => instruction,
		result => decodingResultTypeR
	);

	with opcode select decodingResult <=
		decodingResultTypeI when MIPS_CPU_INSTRUCTION_OPCODE_ADDIU,
		decodingResultTypeI when MIPS_CPU_INSTRUCTION_OPCODE_ANDI,
		decodingResultTypeI when MIPS_CPU_INSTRUCTION_OPCODE_ORI,
		decodingResultTypeI when MIPS_CPU_INSTRUCTION_OPCODE_XORI,
		decodingResultTypeR when MIPS_CPU_INSTRUCTION_OPCODE_SPECIAL;

	register_file_reader : RegisterFileReader port map (
		register_file_output => register_file,
		read_select_1 => decodingResult.regAddr1,
		read_result_1 => regData1,
		read_select_2 => decodingResult.regAddr2,
		read_result_2 => regData2
	);

	alu_operand1 <= regData1;
	with decodingResult.useImmOperand select alu_operand2 <=
		regData2 when '0',
		decodingResult.imm when '1',
		(others => 'X') when others;

	alu_operation <= decodingResult.operation;

	PipelinePhaseInstructionDecode_Process : process (clock, reset)
	begin
		if reset = '0' then
			alu_operand1_output <= (others => '0');
			alu_operand2_output <= (others => '0');
			alu_operation_output <= (others => '0');
			register_destination_output <= (others => '0');
		elsif rising_edge(clock) then
			alu_operand1_output <= alu_operand1;
			alu_operand2_output <= alu_operand2;
			alu_operation_output <= alu_operation;
			register_destination_output <= decodingResult.regDest;
		end if;
	end process;
end Behavioral;
