library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.MIPSCPU.all;

entity PipelinePhaseExecute is
	port (
		reset : in std_logic;
		clock : in std_logic;
		phaseIDInput : in PipelinePhaseIDEXInterface_t;
		pcValue : in std_logic_vector (MIPS_CPU_DATA_WIDTH - 1 downto 0);
		pcControl : out RegisterControl_t;
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
	alu_e: ALU port map (
		number1 => phaseIDInput.operand1,
		number2 => phaseIDInput.operand2,
		operation => phaseIDInput.operation,
		result => result
	);
	with phaseIDInput.targetIsRAM select phaseMACtrl.sourceIsRAM <=
		phaseIDInput.resultIsRAMAddr when FUNC_DISABLED,
		FUNC_DISABLED when FUNC_ENABLED;

	with phaseIDInput.immIsPCValue = FUNC_ENABLED and result(0) = '1' select pcControl.operation <=
		REGISTER_OPERATION_READ when false,
		REGISTER_OPERATION_WRITE when true;

	pcControl.data <= phaseIDInput.extraImm;

	-- TODO: produce an exception when address is not valid.
	phaseMACtrl.sourceRAMAddr <= result(PHYSICS_RAM_ADDRESS_WIDTH + 1 downto 2);

	with phaseIDInput.targetIsRAM select phaseMACtrl.sourceImm <=
		result when FUNC_DISABLED,
		phaseIDInput.extraImm when FUNC_ENABLED;

	phaseMACtrl.targetIsRAM <= phaseIDInput.targetIsRAM;

	with phaseIDInput.targetIsRAM select phaseMACtrl.targetIsReg <=
		FUNC_ENABLED when FUNC_DISABLED,
		FUNC_DISABLED when FUNC_ENABLED;

	-- TODO: produce an exception when address is not valid.
	phaseMACtrl.targetRAMAddr <= result(PHYSICS_RAM_ADDRESS_WIDTH + 1 downto 2);
	phaseMACtrl.targetRegAddr <= phaseIDInput.targetReg;

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
