library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.MIPSCPU.all;
use work.MIPSCP0.all;

entity PipelinePhaseExecute is
	port (
		reset : in std_logic;
		clock : in std_logic;
		phaseIDInput : in PipelinePhaseIDEXInterface_t;
		pcValue : in std_logic_vector (MIPS_CPU_DATA_WIDTH - 1 downto 0);
		pcControl : out RegisterControl_t;
		ramControl : out RAMControl_t;
		phaseMACtrlOutput : out PipelinePhaseEXMAInterface_t;
		phaseIDExceptionTrigger : in CP0ExceptionTrigger_t;
		phaseMAExceptionTrigger : out CP0ExceptionTrigger_t
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
	phaseMACtrl.sourceRAMAddr <= result;

	with phaseIDInput.targetIsRAM select phaseMACtrl.sourceImm <=
		result when FUNC_DISABLED,
		phaseIDInput.extraImm when FUNC_ENABLED;

	phaseMACtrl.targetIsRAM <= phaseIDInput.targetIsRAM;

	with phaseIDInput.targetIsRAM select phaseMACtrl.targetIsReg <=
		FUNC_ENABLED when FUNC_DISABLED,
		FUNC_DISABLED when FUNC_ENABLED;

	-- TODO: produce an exception when address is not valid.
	phaseMACtrl.targetRAMAddr <= result;
	phaseMACtrl.targetRegAddr <= phaseIDInput.targetReg;
	phaseMACtrl.instructionOpcode <= phaseIDInput.instructionOpcode;

	--phaseMACtrlOutput.sourceIsRAM <= phaseMACtrl.sourceIsRAM;
	--phaseMACtrlOutput.sourceRAMAddr <= phaseMACtrl.sourceRAMAddr;
	process(phaseMACtrl)
	begin
		if phaseMACtrl.instructionOpcode = MIPS_CPU_INSTRUCTION_OPCODE_SB or
		phaseMACtrl.instructionOpcode = MIPS_CPU_INSTRUCTION_OPCODE_SH then
			ramControl <= (
				readEnabled => FUNC_ENABLED,
				writeEnabled => FUNC_DISABLED,
				readOnStore => FUNC_ENABLED,
				address => phaseMACtrl.sourceRAMAddr,
				data => (others => '0')
			);
		else
			if phaseMACtrl.instructionOpcode = MIPS_CPU_INSTRUCTION_OPCODE_SW then
				ramControl <= (
					readEnabled => phaseMACtrl.sourceIsRAM,
					writeEnabled => FUNC_DISABLED,
					readOnStore => FUNC_ENABLED,
					address => phaseMACtrl.sourceRAMAddr,
					data => (others => '0')
				);
			else
				ramControl <= (
					readEnabled => phaseMACtrl.sourceIsRAM,
					writeEnabled => FUNC_DISABLED,
					readOnStore => FUNC_DISABLED,
					address => phaseMACtrl.sourceRAMAddr,
					data => (others => '0')
				);
			end if;
		end if;
	end process;
	phaseMAExceptionTrigger <= phaseIDExceptionTrigger;
	PipelinePhaseExecute_Process : process (clock, reset)
	begin
		if reset = '0' then
			phaseMACtrlOutput.targetIsRAM <= FUNC_DISABLED;
			phaseMACtrlOutput.sourceIsRAM <= FUNC_DISABLED;
			phaseMACtrlOutput.targetIsReg <= FUNC_DISABLED;
		elsif rising_edge(clock) then
			phaseMACtrlOutput <= phaseMACtrl;
			--phaseMACtrlOutput.sourceImm <= phaseMACtrl.sourceImm;
			--phaseMACtrlOutput.targetIsRAM <= phaseMACtrl.targetIsRAM;
			--phaseMACtrlOutput.targetIsReg <= phaseMACtrl.targetIsReg;
			--phaseMACtrlOutput.targetRAMAddr <= phaseMACtrl.targetRAMAddr;
			--phaseMACtrlOutput.targetRegAddr <= phaseMACtrl.targetRegAddr;
			--phaseMACtrlOutput.instructionOpcode <= phaseMACtrl.instructionOpcode;
		end if;
	end process;
end Behavioral;
