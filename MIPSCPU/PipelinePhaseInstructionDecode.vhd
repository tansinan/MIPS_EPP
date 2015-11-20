library ieee;
use ieee.std_logic_1164.all;
use work.MIPSCPU.all;

entity PipelinePhaseInstructionDecode is
	port (
		reset : in std_logic;
		clock : in std_logic;
		register_file : in std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
		instruction : in std_logic_vector(MIPS_CPU_INSTRUCTION_WIDTH - 1 downto 0);
		alu_operand1_output : out std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
		alu_operand2_output : out std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
		alu_operation_output : out std_logic_vector(ALU_OPERATION_CTRL_WIDTH - 1 downto 0)
	);
end PipelinePhaseInstructionDecode;

architecture Behavioral of PipelinePhaseInstructionDecode is
	component RegisterFileReader is
		port (
			register_file_output : in mips_register_file_port;
			read_select_1 : in std_logic_vector (MIPS_CPU_REGISTER_ADDRESS_WIDTH - 1 downto 0);
			read_select_2 : in std_logic_vector (MIPS_CPU_REGISTER_ADDRESS_WIDTH - 1 downto 0);
			read_result_1 : out std_logic_vector (MIPS_CPU_DATA_WIDTH - 1 downto 0);
			read_result_2 : out std_logic_vector (MIPS_CPU_DATA_WIDTH - 1 downto 0)
		);
	end component;
	signal instruction_opcode : std_logic_vector(MIPS_CPU_INSTRUCTION_OPCODE_WIDTH - 1 downto 0);
	signal instruction_rs : std_logic_vector(MIPS_CPU_REGISTER_ADDRESS_WIDTH - 1 downto 0);
	signal instruction_rt : std_logic_vector(MIPS_CPU_REGISTER_ADDRESS_WIDTH - 1 downto 0);
	signal instruction_imm : std_logic_vector(MIPS_CPU_REGISTER_IMM_WIDTH - 1 downto 0);
	signal register_file_address1 : std_logic_vector(MIPS_CPU_REGISTER_ADDRESS_WIDTH - 1 downto 0);
	signal register_file_address2 : std_logic_vector(MIPS_CPU_REGISTER_ADDRESS_WIDTH - 1 downto 0);
	signal register_file_oprand1 : std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
	signal register_file_oprand2 : std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
	signal immediate_oprand : std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
	signal alu_oprand1 : std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
	signal alu_oprand2 : std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
	signal alu_operation : std_logic_vector(ALU_OPERATION_CTRL_WIDTH - 1 downto 0);
begin
	register_file_reader: RegisterFileReader port map (
		register_file_output => register_file,
		read_select_1 => register_file_address1,
		read_result_1 => register_file_oprand1,
		read_select_2 => register_file_address2,
		read_result_2 => register_file_oprand2
	);

	instruction_opcode <= instruction (
		MIPS_CPU_INSTRUCTION_OPCODE_HI downto MIPS_CPU_INSTRUCTION_OPCODE_LO
	);

	instruction_rs <= instruction (
		MIPS_CPU_INSTRUCTION_RS_HI downto MIPS_CPU_INSTRUCTION_RS_LO
	);

	instruction_rt <= instruction(
		MIPS_CPU_INSTRUCTION_RT_HI downto MIPS_CPU_INSTRUCTION_RT_LO
	);

	instruction_imm <= instruction(
		MIPS_CPU_INSTRUCTION_IMM_HI downto MIPS_CPU_INSTRUCTION_IMM_LO
	);

	instruction_imm <= instruction(
	MIPS_CPU_INSTRUCTION_IMM_HI downto MIPS_CPU_INSTRUCTION_IMM_LO
	);

	with instruction_opcode select alu_operation <=
	ALU_OPERATION_ADD when MIPS_CPU_INSTRUCTION_OPCODE_ADDIU,
		(others => 'X') when others;

	register_file_address1 <= instruction_rs;
	register_file_address2 <= (others => 'X');

	alu_oprand1 <= register_file_oprand1;
	alu_oprand2 : std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);

	immediate_oprand(MIPS_CPU_DATA_WIDTH downto MIPS_CPU_INSTRUCTION_IMM_HI + 1)
	<= (others => '0');

	immediate_oprand(
		MIPS_CPU_INSTRUCTION_IMM_HI downto MIPS_CPU_INSTRUCTION_IMM_LO
	) <= instruction(
	MIPS_CPU_INSTRUCTION_IMM_HI downto MIPS_CPU_INSTRUCTION_IMM_LO
	);

	alu_oprand2 <= immediate_oprand;

	PipelinePhaseInstructionDecode_Process : process (clock, reset)
	begin
		if reset = '0' then
			alu_operand1_output <= (others => '0');
			alu_operand2_output <= (others => '0');
			alu_operation_output <= (others => '0');
		elsif rising_edge(clock) then
			alu_operand1_output <= alu_operand1;
			alu_operand2_output <= alu_operand2;
			alu_operation_output <= alu_operation;
		end if;
	end process;
end Behavioral;
