library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.MIPSCPU.all;

entity TypeIInstructionDecoder is
	port (
		instruction : in std_logic_vector(MIPS_CPU_INSTRUCTION_WIDTH - 1 downto 0);
		pcValue : in std_logic_vector (MIPS_CPU_DATA_WIDTH - 1 downto 0);
		result : out InstructionDecodingResult_t
	);
end entity;

architecture Behavioral of TypeIInstructionDecoder is
	signal opcode : std_logic_vector(MIPS_CPU_INSTRUCTION_OPCODE_WIDTH - 1 downto 0);
	signal rs : std_logic_vector(MIPS_CPU_REGISTER_ADDRESS_WIDTH - 1 downto 0);
	signal rt : std_logic_vector(MIPS_CPU_REGISTER_ADDRESS_WIDTH - 1 downto 0);
	signal imm : std_logic_vector(MIPS_CPU_INSTRUCTION_IMM_WIDTH - 1 downto 0);
begin
	opcode <= instruction(MIPS_CPU_INSTRUCTION_OPCODE_HI downto MIPS_CPU_INSTRUCTION_OPCODE_LO);
	rs <= instruction(MIPS_CPU_INSTRUCTION_RS_HI downto MIPS_CPU_INSTRUCTION_RS_LO);
	rt <= instruction(MIPS_CPU_INSTRUCTION_RT_HI downto MIPS_CPU_INSTRUCTION_RT_LO);
	imm <= instruction(MIPS_CPU_INSTRUCTION_IMM_HI downto MIPS_CPU_INSTRUCTION_IMM_LO);

	process(opcode, rs, rt, imm, pcValue, instruction)
		variable zeroExtendedImm : std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
		variable signExtendedImm : std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
		variable signExtendedAddrImm : std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
	begin
		zeroExtendedImm(MIPS_CPU_DATA_WIDTH - 1 downto MIPS_CPU_INSTRUCTION_IMM_HI + 1)
			:= (others => '0');

		zeroExtendedImm(MIPS_CPU_INSTRUCTION_IMM_HI downto MIPS_CPU_INSTRUCTION_IMM_LO)
			:= imm(MIPS_CPU_INSTRUCTION_IMM_HI downto MIPS_CPU_INSTRUCTION_IMM_LO);

		signExtendedImm(MIPS_CPU_DATA_WIDTH - 1 downto MIPS_CPU_INSTRUCTION_IMM_HI + 1)
			:= (others => instruction(MIPS_CPU_INSTRUCTION_IMM_HI));

		signExtendedImm(MIPS_CPU_INSTRUCTION_IMM_HI downto MIPS_CPU_INSTRUCTION_IMM_LO)
			:= imm(MIPS_CPU_INSTRUCTION_IMM_HI downto MIPS_CPU_INSTRUCTION_IMM_LO);
			
		signExtendedAddrImm(MIPS_CPU_DATA_WIDTH - 1 downto 2) :=
			signExtendedImm(MIPS_CPU_DATA_WIDTH - 3 downto 0);
			
		signExtendedAddrImm(1 downto 0) := "00";

		case opcode is
			when MIPS_CPU_INSTRUCTION_OPCODE_ADDIU =>
				result.operation <= ALU_OPERATION_ADD;
				result.resultIsRAMAddr <= FUNC_DISABLED;
				result.pcControl.operation <= REGISTER_OPERATION_READ;
				result.imm <= signExtendedImm;
				result.regAddr1 <= rs;
				result.regAddr2 <= rt;
				result.regDest <= rt;
				result.useImmOperand <= '1';
				result.immIsPCValue <= FUNC_DISABLED;
			when MIPS_CPU_INSTRUCTION_OPCODE_ANDI =>
				result.operation <= ALU_OPERATION_LOGIC_AND;
				result.resultIsRAMAddr <= FUNC_DISABLED;
				result.pcControl.operation <= REGISTER_OPERATION_READ;
				result.imm <= zeroExtendedImm;
				result.regAddr1 <= rs;
				result.regAddr2 <= rt;
				result.regDest <= rt;
				result.useImmOperand <= '1';
				result.immIsPCValue <= FUNC_DISABLED;
			when MIPS_CPU_INSTRUCTION_OPCODE_ORI =>
				result.operation <= ALU_OPERATION_LOGIC_OR;
				result.resultIsRAMAddr <= FUNC_DISABLED;
				result.pcControl.operation <= REGISTER_OPERATION_READ;
				result.imm <= zeroExtendedImm;
				result.regAddr1 <= rs;
				result.regAddr2 <= rt;
				result.regDest <= rt;
				result.useImmOperand <= '1';
				result.immIsPCValue <= FUNC_DISABLED;
			when MIPS_CPU_INSTRUCTION_OPCODE_XORI =>
				result.operation <= ALU_OPERATION_LOGIC_XOR;
				result.resultIsRAMAddr <= FUNC_DISABLED;
				result.pcControl.operation <= REGISTER_OPERATION_READ;
				result.imm <= zeroExtendedImm;
				result.regAddr1 <= rs;
				result.regAddr2 <= rt;
				result.regDest <= rt;
				result.useImmOperand <= '1';
				result.immIsPCValue <= FUNC_DISABLED;
			when MIPS_CPU_INSTRUCTION_OPCODE_LW =>
				result.operation <= ALU_OPERATION_ADD;
				result.resultIsRAMAddr <= FUNC_ENABLED;
				result.pcControl.operation <= REGISTER_OPERATION_READ;
				result.imm <= signExtendedImm;
				result.regAddr1 <= rs;
				result.regAddr2 <= rt;
				result.regDest <= rt;
				result.useImmOperand <= '1';
				result.immIsPCValue <= FUNC_DISABLED;
			when MIPS_CPU_INSTRUCTION_OPCODE_SW =>
				result.operation <= ALU_OPERATION_ADD;
				result.resultIsRAMAddr <= FUNC_ENABLED;
				result.pcControl.operation <= REGISTER_OPERATION_READ;
				result.imm <= signExtendedImm;
				result.regAddr1 <= rs;
				result.regAddr2 <= rt;
				result.regDest <= rt;
				result.useImmOperand <= '1';
				result.immIsPCValue <= FUNC_DISABLED;
			when MIPS_CPU_INSTRUCTION_OPCODE_BNE =>
				result.operation <= ALU_OPERATION_NOT_EQUAL;
				result.resultIsRAMAddr <= FUNC_DISABLED;
				result.pcControl.operation <= REGISTER_OPERATION_READ;
				result.imm <= signExtendedAddrImm + pcValue;
				result.regAddr1 <= rs;
				result.regAddr2 <= rt;
				result.regDest <= (others => '0');
				result.useImmOperand <= '0';
				result.immIsPCValue <= FUNC_ENABLED;
			when others =>
				result.operation <= ALU_OPERATION_ADD;
				result.resultIsRAMAddr <= FUNC_DISABLED;
				result.pcControl.operation <= REGISTER_OPERATION_READ;
				result.regAddr1 <= (others => '0');
				result.regAddr2 <= (others => '0');
				result.regDest <= (others => '0');
				result.useImmOperand <= '1';
				result.immIsPCValue <= FUNC_DISABLED;
		end case;
	end process;

end architecture;
