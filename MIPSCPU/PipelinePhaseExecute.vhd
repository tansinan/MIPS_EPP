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
		useRAMAddr : in std_logic;
		phaseMACtrlOutput : out PipelinePhaseEXMAInterface_t
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
	signal phaseMACtrl : PipelinePhaseEXMAInterface_t;
begin
	alu_entity: ALU port map (
		number1 => operand1,
		number2 => operand2,
		operation => operation,
		result => result
	);
	phaseMACtrl.sourceIsRAM <= useRAMAddr;
	phaseMACtrl.sourceRAMAddr <= (others => '0');
	phaseMACtrl.sourceImm <= result;
	phaseMACtrl.targetIsRAM <= FUNC_DISABLED;
	phaseMACtrl.targetIsReg <= FUNC_ENABLED;
	phaseMACtrl.targetRAMAddr <= (others => '0');
	phaseMACtrl.targetRegAddr <= register_destination;
	PipelinePhaseExecute_Process : process (clock, reset)
	begin
		if reset = '0' then
			phaseMACtrlOutput.targetIsRAM <= FUNC_DISABLED;
			phaseMACtrlOutput.sourceIsRAM <= FUNC_DISABLED;
			phaseMACtrlOutput.targetIsReg <= FUNC_DISABLED;
		elsif rising_edge(clock) then
			phaseMACtrlOutput <= phaseMACtrl;
		end if;
	end process;
end Behavioral;
