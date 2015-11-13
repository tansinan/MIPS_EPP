library ieee;
use ieee.std_logic_1164.all;
use work.MIPSCPU.all;

entity PipelinePhaseInstructionDecode is
    port ( 
		instruction : in std_logic_vector(MIPS_CPU_INSTRUCTION_WIDTH - 1 downto 0);
		alu_number1 : in std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
		alu_number2 : in std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
		alu_operation : in std_logic_vector(ALU_OPERATION_CTRL_WIDTH - 1 downto 0)
	);
end PipelinePhaseInstructionDecode;

architecture Behavioral of PipelinePhaseInstructionDecode is
begin


end Behavioral;

