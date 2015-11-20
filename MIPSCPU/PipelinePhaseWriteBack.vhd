library ieee;
use ieee.std_logic_1164.all;
use work.MIPSCPU.all;

entity PipelinePhaseWriteBack is
    port (
		reset : in std_logic;
		clock : in std_logic;
		register_file_input : out std_logic_vector (MIPS_CPU_DATA_WIDTH - 1 downto 0);
		register_file_operation : out std_logic_vector (MIPS_CPU_REGISTER_COUNT - 1 downto 0);
		operation_result : in std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
		register_destination : in std_logic_vector(MIPS_CPU_REGISTER_ADDRESS_WIDTH - 1 downto 0);
		instruction_done : out std_logic
	);
end PipelinePhaseWriteBack;

architecture Behavioral of PipelinePhaseWriteBack is
	component RegisterFileWriter is
    port (
		write_select : in std_logic_vector(MIPS_CPU_REGISTER_ADDRESS_WIDTH - 1 downto 0);
		write_data : in std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
		operation_output : out std_logic_vector(MIPS_CPU_REGISTER_COUNT - 1 downto 0);
		data_output : out std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0)
	);
	end component;
begin
	register_file_writer_component: RegisterFileWriter port map (
		write_select => register_destination,
		write_data => operation_result,
		operation_output => register_file_operation,
		data_output => register_file_input
	);
	
	instruction_done <= '1';
	
end Behavioral;
