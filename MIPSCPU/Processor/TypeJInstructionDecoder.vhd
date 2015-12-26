library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.MIPSCPU.all;

entity TypeJInstructionDecoder is
	port (
		instruction : in std_logic_vector(MIPS_CPU_INSTRUCTION_WIDTH - 1 downto 0);
		pcValue : in std_logic_vector (MIPS_CPU_DATA_WIDTH - 1 downto 0);
		registerFile : in mips_register_file_port;
		result : out InstructionDecodingResult_t
	);
end entity;

architecture Behavioral of TypeJInstructionDecoder is
	signal opcode : std_logic_vector(MIPS_CPU_INSTRUCTION_OPCODE_WIDTH - 1 downto 0);
begin
	process(instruction, pcValue, registerFile, opcode)
	begin
		opcode <= instruction
			(MIPS_CPU_INSTRUCTION_OPCODE_HI downto MIPS_CPU_INSTRUCTION_OPCODE_LO);

		result <= INSTRUCTION_DECODING_RESULT_CLEAR;
		result.pcControl.operation <= REGISTER_OPERATION_WRITE;
		result.pcControl.data(1 downto 0) <= (others => '0');
		-- TODO: This implementation seems not compliant with MIPS standard!
		-- The upper bits should be the instruction in the branch delay slot.
		result.pcControl.data
			(MIPS_CPU_DATA_WIDTH - 1 downto MIPS_CPU_INSTRUCTION_OPCODE_LO + 2) <=
		pcValue(MIPS_CPU_DATA_WIDTH - 1 downto MIPS_CPU_INSTRUCTION_OPCODE_LO + 2);

		result.pcControl.data(MIPS_CPU_INSTRUCTION_OPCODE_LO + 1 downto 2) <=
		instruction(MIPS_CPU_INSTRUCTION_OPCODE_LO - 1 downto 0);

		result.resultIsRAMAddr <= FUNC_DISABLED;
		result.immIsPCValue <= FUNC_DISABLED;
		case opcode is
			when MIPS_CPU_INSTRUCTION_OPCODE_J =>
				result.regAddr1 <= (others => '0');
				result.regAddr2 <= (others => '0');
				result.regDest <= (others => '0');
				result.operation <= ALU_OPERATION_LOGIC_OR;
				result.imm <= (others => '0');
				result.useImmOperand <= '0';
			-- !This implementation may not fully compliant with the way suggested by MIPS.
			when MIPS_CPU_INSTRUCTION_OPCODE_JAL =>
				result.regAddr1 <= (others => '0');
				result.regAddr2 <= (others => '0');
				result.regDest <= "11111";
				result.operation <= ALU_OPERATION_LOGIC_OR;
				-- TODO: This should be performed by ALU but requires pipeline modification.
				result.imm <= pcValue + 4;
				result.useImmOperand <= '1';
			when others =>
				result.regAddr1 <= (others => '0');
				result.regAddr2 <= (others => '0');
				result.regDest <= (others => '0');
				result.operation <= ALU_OPERATION_LOGIC_OR;
				result.imm <= (others => '0');
				result.useImmOperand <= '0';
		end case;
	end process;
end architecture;
