library ieee;
use ieee.std_logic_1164.all;
use work.MIPSCPU.all;

entity PipelinePhaseWriteBack is
	port (
		reset : in std_logic;
		clock : in std_logic;
		ramWriteControl : out RAMWriteControl_t;
		registerFileControl : out RegisterFileControl_t;
		phaseMAInput : in PipelinePhaseMAWBInterface_t;
		instruction_done : out std_logic
	);
end entity;

architecture Behavioral of PipelinePhaseWriteBack is
begin
	registerFileControl <= (
		address => phaseMAInput.targetRegAddr,
		data => phaseMAInput.sourceImm
	);
	ramWriteControl.enable <= phaseMAInput.targetIsRAM;
	ramWriteControl.address <= phaseMAInput.targetRAMAddr;
	ramWriteControl.data <= phaseMAInput.sourceImm;
	instruction_done <= '1';

end Behavioral;
