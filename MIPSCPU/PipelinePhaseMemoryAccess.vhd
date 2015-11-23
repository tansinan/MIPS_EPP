library ieee;
use ieee.std_logic_1164.all;
use work.MIPSCPU.all;


entity PipelinePhaseMemoryAccess is
	port (
		clock : in std_logic;
		reset : in std_logic;
		phaseEXInput : in PipelinePhaseEXMAInterface_t;
		phaseWBCtrlOutput : out PipelinePhaseMAWBInterface_t;
		ramReadControl : out RAMReadControl_t;
		ramReadResult : in std_logic_vector(PHYSICS_RAM_DATA_WIDTH - 1 downto 0)
	);
end PipelinePhaseMemoryAccess;

architecture Behavioral of PipelinePhaseMemoryAccess is
	signal phaseWBCtrl : PipelinePhaseMAWBInterface_t;
begin
	ramReadControl.enable <= phaseEXInput.sourceIsRAM;
	ramReadControl.address <= phaseEXInput.sourceRAMAddr;
	with phaseEXInput.sourceIsRAM select phaseWBCtrl.sourceImm <=
		ramReadResult when FUNC_ENABLED,
		phaseEXInput.sourceImm when FUNC_DISABLED;
	phaseWBCtrl.targetIsRAM <= phaseEXInput.targetIsRAM;
	phaseWBCtrl.targetIsReg <= phaseEXInput.targetIsReg;
	phaseWBCtrl.targetRAMAddr <= phaseEXInput.targetRAMAddr;
	phaseWBCtrl.targetRegAddr <= phaseEXInput.targetRegAddr;
	process(clock, reset)
	begin
		if reset = FUNC_ENABLED then
			phaseWBCtrlOutput.targetIsReg <= FUNC_DISABLED;
			phaseWBCtrlOutput.targetIsRAM <= FUNC_DISABLED;
		elsif rising_edge(clock) then
			phaseWBCtrlOutput <= phaseWBCtrl;
		end if;
	end process;
end Behavioral;
