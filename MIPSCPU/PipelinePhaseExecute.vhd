library ieee;
use ieee.std_logic_1164.all;
use work.MIPSCPU.all;

entity PipelinePhaseExecute is
	port (
		reset : in std_logic;
		clock : in std_logic;
		operand1 : in std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
		operand2 : in std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
		operation : in std_logic_vector(ALU_OPERATION_CTRL_WIDTH - 1 downto 0);
		register_destination : in std_logic_vector(MIPS_CPU_REGISTER_ADDRESS_WIDTH - 1 downto 0);
		result_output : out std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
		register_destination_output : out std_logic_vector(MIPS_CPU_REGISTER_ADDRESS_WIDTH - 1 downto 0)
	);
end entity;

architecture Behavioral of PipelinePhaseExecute is
	component ALU is
		port(
			number1 : in std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
			number2 : in std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
			operation : in std_logic_vector(ALU_OPERATION_CTRL_WIDTH - 1 downto 0);
			result : out std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0)
		);
	end component;
	signal result : std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
begin
	alu_entity: ALU port map (
		number1 => operand1,
		number2 => operand2,
		operation => operation,
		result => result
	);
	PipelinePhaseExecute_Process : process (clock, reset)
	begin
		if reset = '0' then
			result_output <= (others => '0');
		elsif rising_edge(clock) then
			result_output <= result;
			register_destination_output <= register_destination;
		end if;
	end process;
end Behavioral;
