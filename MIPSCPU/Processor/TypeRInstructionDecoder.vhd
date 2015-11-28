library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.MIPSCPU.all;

entity TypeRInstructionDecoder is
	port (
		instruction : in std_logic_vector(MIPS_CPU_INSTRUCTION_WIDTH - 1 downto 0);
		pcValue : in std_logic_vector (MIPS_CPU_DATA_WIDTH - 1 downto 0);
		registerFile : in mips_register_file_port;
		result : out InstructionDecodingResult_t
	);
end entity;

architecture Behavioral of TypeRInstructionDecoder is
	signal rs : std_logic_vector (MIPS_CPU_REGISTER_ADDRESS_WIDTH - 1 downto 0);
	signal rt : std_logic_vector (MIPS_CPU_REGISTER_ADDRESS_WIDTH - 1 downto 0);
	signal rd : std_logic_vector (MIPS_CPU_REGISTER_ADDRESS_WIDTH - 1 downto 0);
	signal opcode : std_logic_vector (MIPS_CPU_INSTRUCTION_OPCODE_WIDTH - 1 downto 0);
	signal funct : std_logic_vector (MIPS_CPU_INSTRUCTION_FUNCT_WIDTH - 1 downto 0);
	signal shamt : std_logic_vector (MIPS_CPU_INSTRUCTION_SHAMT_WIDTH - 1 downto 0);
	signal rsData : std_logic_vector (MIPS_CPU_DATA_WIDTH - 1 downto 0);

	component RegisterFileReader is
		port (
			register_file_output : in mips_register_file_port;
			readSelect : in std_logic_vector (MIPS_CPU_REGISTER_ADDRESS_WIDTH - 1 downto 0);
			readResult : out std_logic_vector (MIPS_CPU_DATA_WIDTH - 1 downto 0)
		);
	end component;
begin
	rs <= instruction(MIPS_CPU_INSTRUCTION_RS_HI downto MIPS_CPU_INSTRUCTION_RS_LO);
	rt <= instruction(MIPS_CPU_INSTRUCTION_RT_HI downto MIPS_CPU_INSTRUCTION_RT_LO);
	rd <= instruction(MIPS_CPU_INSTRUCTION_RD_HI downto MIPS_CPU_INSTRUCTION_RD_LO);
	opcode <= instruction(MIPS_CPU_INSTRUCTION_OPCODE_HI downto MIPS_CPU_INSTRUCTION_OPCODE_LO);
	funct <= instruction(MIPS_CPU_INSTRUCTION_FUNCT_HI downto MIPS_CPU_INSTRUCTION_FUNCT_LO);
	shamt <= instruction(MIPS_CPU_INSTRUCTION_SHAMT_HI downto MIPS_CPU_INSTRUCTION_SHAMT_LO);

	registerFileReader_e : RegisterFileReader port map (
		register_file_output => registerFile,
		readSelect => rs,
		readResult => rsData
	);
	process(rs, rt, rd, opcode, funct, shamt)
	begin
		case funct is
			
			-- Handles shift instructions using the shamt field as immediate
			when MIPS_CPU_INSTRUCTION_FUNCT_SLL |
			MIPS_CPU_INSTRUCTION_FUNCT_SRL |
			MIPS_CPU_INSTRUCTION_FUNCT_SRA =>
				result.regAddr1 <= rs;
				result.regAddr2 <= (others => '0');
				result.regDest <= rd;
				result.imm(MIPS_CPU_INSTRUCTION_SHAMT_WIDTH - 1 downto 0) <= shamt;
				result.imm(MIPS_CPU_DATA_WIDTH - 1 downto MIPS_CPU_INSTRUCTION_SHAMT_WIDTH) <= 
					(others => '0');
				result.useImmOperand <= '1';
				result.resultIsRAMAddr <= FUNC_DISABLED;
				result.immIsPCValue <= FUNC_DISABLED;
				result.pcControl <= (
					operation => REGISTER_OPERATION_READ,
					data => (others => '0')
				);
				case funct is
					when MIPS_CPU_INSTRUCTION_FUNCT_SLL =>
						result.operation <= ALU_OPERATION_SHIFT_LEFT;
					when MIPS_CPU_INSTRUCTION_FUNCT_SRL =>
						result.operation <= ALU_OPERATION_SHIFT_RIGHT_LOGIC;
					when MIPS_CPU_INSTRUCTION_FUNCT_SRA =>
						result.operation <= ALU_OPERATION_SHIFT_RIGHT_ARITH;
					when others =>
						result.operation <= (others => 'X');
				end case;
			when MIPS_CPU_INSTRUCTION_FUNCT_JR =>
				result.regAddr1 <= (others => '0');
				result.regAddr2 <= (others => '0');
				result.regDest <= rd;
				result.operation <= ALU_OPERATION_LOGIC_OR;
				-- !TODO This should be performed by ALU. Need pipeline change.
				result.imm <= pcValue + 4;
				result.useImmOperand <= '1';
				result.resultIsRAMAddr <= FUNC_DISABLED;
				result.immIsPCValue <= FUNC_DISABLED;
				result.pcControl <= (
					operation => REGISTER_OPERATION_WRITE,
					data => rsData
				);
			when MIPS_CPU_INSTRUCTION_FUNCT_JALR =>
				result.regAddr1 <= (others => '0');
				result.regAddr2 <= (others => '0');
				result.regDest <= (others => '0');
				result.operation <= ALU_OPERATION_LOGIC_OR;
				result.imm <= (others => '0');
				result.useImmOperand <= '0';
				result.resultIsRAMAddr <= FUNC_DISABLED;
				result.immIsPCValue <= FUNC_DISABLED;
				result.pcControl <= (
					operation => REGISTER_OPERATION_WRITE,
					data => rsData
				);
			-- Handles general R type arith instructions, where shamt is constant.
			when others =>
				result.regAddr1 <= rs;
				result.regAddr2 <= rt;
				result.regDest <= rd;
				result.imm <= (others => 'X');
				result.useImmOperand <= '0';
				result.resultIsRAMAddr <= FUNC_DISABLED;
				result.immIsPCValue <= FUNC_DISABLED;
				case funct is
					when MIPS_CPU_INSTRUCTION_FUNCT_ADDU =>
						result.operation <= ALU_OPERATION_ADD;
					when MIPS_CPU_INSTRUCTION_FUNCT_SUBU =>
						result.operation <= ALU_OPERATION_SUBTRACT;
					when MIPS_CPU_INSTRUCTION_FUNCT_OR =>
						result.operation <= ALU_OPERATION_LOGIC_OR;
					when MIPS_CPU_INSTRUCTION_FUNCT_XOR =>
						result.operation <= ALU_OPERATION_LOGIC_XOR;
					when MIPS_CPU_INSTRUCTION_FUNCT_NOR =>
						result.operation <= ALU_OPERATION_LOGIC_NOR;
					when MIPS_CPU_INSTRUCTION_FUNCT_SLT =>
						result.operation <= ALU_OPERATION_LESS_THAN_SIGNED;
					when MIPS_CPU_INSTRUCTION_FUNCT_SLTU =>
						result.operation <= ALU_OPERATION_LESS_THAN_UNSIGNED;
					when MIPS_CPU_INSTRUCTION_FUNCT_SLLV =>
						result.operation <= ALU_OPERATION_SHIFT_LEFT;
					when MIPS_CPU_INSTRUCTION_FUNCT_SRLV =>
						result.operation <= ALU_OPERATION_SHIFT_RIGHT_LOGIC;
					when MIPS_CPU_INSTRUCTION_FUNCT_SRAV =>
						result.operation <= ALU_OPERATION_SHIFT_RIGHT_ARITH;
					when others =>
						result.operation <= (others => 'X');
				end case;
		end case;
	end process;

end architecture;
