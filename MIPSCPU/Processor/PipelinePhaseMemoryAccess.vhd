library ieee;
use ieee.std_logic_1164.all;
use work.MIPSCPU.all;


entity PipelinePhaseMemoryAccess is
	port (
		clock : in std_logic;
		reset : in std_logic;
		phaseEXInput : in PipelinePhaseEXMAInterface_t;
		phaseWBCtrlOutput : out PipelinePhaseMAWBInterface_t;
		ramReadResult : in std_logic_vector(MIPS_RAM_DATA_WIDTH - 1 downto 0)
	);
end PipelinePhaseMemoryAccess;

architecture Behavioral of PipelinePhaseMemoryAccess is
	signal phaseWBCtrl : PipelinePhaseMAWBInterface_t;
begin
	process(phaseEXInput, ramReadResult)
		variable loadByteResult : std_logic_vector(7 downto 0);
	begin
		case phaseEXInput.sourceRAMAddr(1 downto 0) is
			when "00" =>
				loadByteResult := ramReadResult(7 downto 0);
			when "01" =>
				loadByteResult := ramReadResult(15 downto 8);
			when "10" =>
				loadByteResult := ramReadResult(23 downto 16);
			when "11" =>
				loadByteResult := ramReadResult(MIPS_CPU_DATA_WIDTH - 1 downto 24);
			when others =>
				report "Warning: meta value detected for the LBU address";
		end case;
		case phaseExInput.instructionOpcode is
			when MIPS_CPU_INSTRUCTION_OPCODE_LW =>
				phaseWBCtrl.sourceImm <= ramReadResult;
			when MIPS_CPU_INSTRUCTION_OPCODE_LH =>
				phaseWBCtrl.sourceImm(15 downto 0) <= ramReadResult(15 downto 0);
				phaseWBCtrl.sourceImm(MIPS_CPU_DATA_WIDTH - 1 downto 16) <=
					(others => ramReadResult(15));
			when MIPS_CPU_INSTRUCTION_OPCODE_LHU =>
				phaseWBCtrl.sourceImm(15 downto 0) <= ramReadResult(15 downto 0);
				phaseWBCtrl.sourceImm(MIPS_CPU_DATA_WIDTH - 1 downto 16) <= (others => '0');
			when MIPS_CPU_INSTRUCTION_OPCODE_LB =>
				phaseWBCtrl.sourceImm(MIPS_CPU_DATA_WIDTH - 1 downto 8)
					<= (others => loadByteResult(7));
				phaseWBCtrl.sourceImm(7 downto 0) <= loadByteResult;
			when MIPS_CPU_INSTRUCTION_OPCODE_LBU =>
				phaseWBCtrl.sourceImm(MIPS_CPU_DATA_WIDTH - 1 downto 8) <= (others => '0');
				phaseWBCtrl.sourceImm(7 downto 0) <= loadByteResult;
			when MIPS_CPU_INSTRUCTION_OPCODE_SH =>
				phaseWBCtrl.sourceImm(15 downto 0) <= phaseExInput.sourceImm(15 downto 0);
				phaseWBCtrl.sourceImm(MIPS_CPU_DATA_WIDTH - 1 downto 16) <= 
					ramReadResult(MIPS_CPU_DATA_WIDTH - 1 downto 16);
			when MIPS_CPU_INSTRUCTION_OPCODE_SB =>
				phaseWBCtrl.sourceImm(7 downto 0) <= phaseExInput.sourceImm(7 downto 0);
				phaseWBCtrl.sourceImm(MIPS_CPU_DATA_WIDTH - 1 downto 8) <= 
					ramReadResult(MIPS_CPU_DATA_WIDTH - 1 downto 8);
			when others =>
				phaseWBCtrl.sourceImm <= phaseEXInput.sourceImm;
		end case;
		phaseWBCtrl.targetIsRAM <= phaseEXInput.targetIsRAM;
		phaseWBCtrl.targetIsReg <= phaseEXInput.targetIsReg;
		phaseWBCtrl.targetRAMAddr <= phaseEXInput.targetRAMAddr;
		phaseWBCtrl.targetRegAddr <= phaseEXInput.targetRegAddr;
		phaseWBCtrl.instructionOpcode <= phaseEXInput.instructionOpcode;
	end process;

	phaseWBCtrlOutput <= phaseWBCtrl;
	process(clock, reset)
	begin
		if reset = FUNC_ENABLED then
			--phaseWBCtrlOutput.targetIsReg <= FUNC_DISABLED;
			--phaseWBCtrlOutput.targetIsRAM <= FUNC_DISABLED;
		elsif rising_edge(clock) then
			
		end if;
	end process;
end Behavioral;
