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
		writeBackToRAM : in std_logic;
		extraData : in std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
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
	with writeBackToRAM select phaseMACtrl.sourceIsRAM <=
		useRAMAddr when FUNC_DISABLED,
		FUNC_DISABLED when FUNC_ENABLED;

	-- TODO: produce an exception when address is not valid.
	phaseMACtrl.sourceRAMAddr <= result(PHYSICS_RAM_ADDRESS_WIDTH + 1 downto 2);
	with writeBackToRAM select phaseMACtrl.sourceImm <=
		result when FUNC_DISABLED,
		extraData when FUNC_ENABLED;
	phaseMACtrl.targetIsRAM <= writeBackToRAM;
	with writeBackToRAM select phaseMACtrl.targetIsReg <=
		FUNC_ENABLED when FUNC_DISABLED,
		FUNC_DISABLED when FUNC_ENABLED;

	-- TODO: produce an exception when address is not valid.
	phaseMACtrl.targetRAMAddr <= result(PHYSICS_RAM_ADDRESS_WIDTH + 1 downto 2);
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
