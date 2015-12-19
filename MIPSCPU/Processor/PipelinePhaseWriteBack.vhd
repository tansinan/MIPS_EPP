library ieee;
use ieee.std_logic_1164.all;
use work.MIPSCPU.all;

entity PipelinePhaseWriteBack is
	port (
		ramControl : out RAMControl_t;
		registerFileControl : out RegisterFileControl_t;
		phaseMAInput : in PipelinePhaseMAWBInterface_t
	);
end entity;

architecture Behavioral of PipelinePhaseWriteBack is
begin
	-- If target is register file, this will trigger the
	-- register data to be updated at next cycle.
	registerFileControl <= (
		address => phaseMAInput.targetRegAddr,
		data => phaseMAInput.sourceImm
	);
	
	-- If target is RAM, this will trigger RAM data to be
	-- updated in next cycle.
	ramControl <= (
		writeEnabled => phaseMAInput.targetIsRAM,
		readEnabled => FUNC_DISABLED,
		readOnStore => FUNC_DISABLED,
		address => phaseMAInput.targetRAMAddr,
		data => phaseMAInput.sourceImm
	);

end Behavioral;
