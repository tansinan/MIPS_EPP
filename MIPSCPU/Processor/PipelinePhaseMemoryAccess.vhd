library ieee;
use ieee.std_logic_1164.all;
use work.MIPSCPU.all;
use work.MIPSCP0.all;

entity PipelinePhaseMemoryAccess is
	port (
		clock : in std_logic;
		reset : in std_logic;
		phaseEXInput : in PipelinePhaseEXMAInterface_t;
		phaseWBCtrlOutput : out PipelinePhaseMAWBInterface_t;
		exceptionTriggerOutput : out CP0ExceptionTrigger_t;
		ramReadResult : in std_logic_vector(MIPS_RAM_DATA_WIDTH - 1 downto 0);
		ramReadException : in CP0ExceptionTrigger_t;
		phaseEXExceptionTrigger : out CP0ExceptionTrigger_t
	);
end entity;

architecture Behavioral of PipelinePhaseMemoryAccess is
	signal phaseWBCtrl : PipelinePhaseMAWBInterface_t;
	signal exceptionTrigger : CP0ExceptionTrigger_t;
begin
	process(phaseEXInput)
	begin
		if ramReadException.enabled = FUNC_ENABLED then
			exceptionTrigger <= ramReadException;
		else
			case phaseEXInput.instructionOpcode is
				when MIPS_CPU_INSTRUCTION_OPCODE_LW |
					MIPS_CPU_INSTRUCTION_OPCODE_SW =>
					if phaseEXInput.sourceRAMAddr(1 downto 0) /= "00" then
						exceptionTrigger.enabled <= FUNC_ENABLED;
						if phaseEXInput.instructionOpcode = MIPS_CPU_INSTRUCTION_OPCODE_SW then
							exceptionTrigger.exceptionCode <= MIPS_CP0_CAUSE_EXCEPTION_CODE_ADDRESS_STORE;
						else
							exceptionTrigger.exceptionCode <= MIPS_CP0_CAUSE_EXCEPTION_CODE_ADDRESS_LOAD;
						end if;
						report "Unaligned LW/SW detected!";
					else
						exceptionTrigger.enabled <= FUNC_DISABLED;
					end if;
				when MIPS_CPU_INSTRUCTION_OPCODE_LH |
					MIPS_CPU_INSTRUCTION_OPCODE_LHU |
					MIPS_CPU_INSTRUCTION_OPCODE_SH =>
					if phaseEXInput.sourceRAMAddr(0) /= '0' then
						exceptionTrigger.enabled <= FUNC_ENABLED;
						if phaseEXInput.instructionOpcode = MIPS_CPU_INSTRUCTION_OPCODE_SH then
							exceptionTrigger.exceptionCode <= MIPS_CP0_CAUSE_EXCEPTION_CODE_ADDRESS_STORE;
						else
							exceptionTrigger.exceptionCode <= MIPS_CP0_CAUSE_EXCEPTION_CODE_ADDRESS_LOAD;
						end if;
					else
						exceptionTrigger.enabled <= FUNC_DISABLED;
					end if;
				when others =>
					exceptionTrigger.enabled <= FUNC_DISABLED;
			end case;
			exceptionTrigger.badVirtualAddress <= (others => '0');
		end if;
	end process;

	process(phaseEXInput, ramReadResult)
		variable loadByteResult : std_logic_vector(7 downto 0);
		variable loadHalfWordResult : std_logic_vector(15 downto 0);
		variable storeByteResult : std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
		variable storeHalfwordResult : std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
	begin
		storeByteResult := ramReadResult;
		case phaseEXInput.sourceRAMAddr(1 downto 0) is
			when "00" =>
				loadByteResult := ramReadResult(7 downto 0);
				storeByteResult(7 downto 0) := phaseEXInput.sourceImm(7 downto 0);
			when "01" =>
				loadByteResult := ramReadResult(15 downto 8);
				storeByteResult(15 downto 8) := phaseEXInput.sourceImm(7 downto 0);
			when "10" =>
				loadByteResult := ramReadResult(23 downto 16);
				storeByteResult(23 downto 16) := phaseEXInput.sourceImm(7 downto 0);
			when "11" =>
				loadByteResult := ramReadResult(MIPS_CPU_DATA_WIDTH - 1 downto 24);
				storeByteResult(MIPS_CPU_DATA_WIDTH - 1 downto 24)
					:= phaseEXInput.sourceImm(7 downto 0);
			when others =>
				report "Warning: meta value detected for the LB/LBU address";
		end case;
		case phaseEXInput.sourceRAMAddr(1) is
			when '0' =>
				loadHalfWordResult := ramReadResult(15 downto 0);
				storeHalfWordResult(MIPS_CPU_DATA_WIDTH - 1 downto 16) :=
					ramReadResult(MIPS_CPU_DATA_WIDTH - 1 downto 16);
				storeHalfWordResult(15 downto 0) := phaseEXInput.sourceImm(15 downto 0);
			when '1' =>
				loadHalfWordResult := ramReadResult(MIPS_CPU_DATA_WIDTH - 1 downto 16);
				storeHalfWordResult(MIPS_CPU_DATA_WIDTH - 1 downto 16)
					:= phaseEXInput.sourceImm(15 downto 0);
				storeHalfWordResult(15 downto 0) := ramReadResult(15 downto 0);
			when others =>
				report "Warning: meta value detected for the LH/LHU address";
		end case;
		case phaseExInput.instructionOpcode is
			when MIPS_CPU_INSTRUCTION_OPCODE_LW =>
				phaseWBCtrl.sourceImm <= ramReadResult;
			when MIPS_CPU_INSTRUCTION_OPCODE_LH =>
				phaseWBCtrl.sourceImm(MIPS_CPU_DATA_WIDTH - 1 downto 16)
					<= (others => loadHalfWordResult(15));
				phaseWBCtrl.sourceImm(15 downto 0) <= loadHalfWordResult;
			when MIPS_CPU_INSTRUCTION_OPCODE_LHU =>
				phaseWBCtrl.sourceImm(MIPS_CPU_DATA_WIDTH - 1 downto 16) <= (others => '0');
				phaseWBCtrl.sourceImm(15 downto 0) <= loadHalfWordResult;
			when MIPS_CPU_INSTRUCTION_OPCODE_LB =>
				phaseWBCtrl.sourceImm(MIPS_CPU_DATA_WIDTH - 1 downto 8)
					<= (others => loadByteResult(7));
				phaseWBCtrl.sourceImm(7 downto 0) <= loadByteResult;
			when MIPS_CPU_INSTRUCTION_OPCODE_LBU =>
				phaseWBCtrl.sourceImm(MIPS_CPU_DATA_WIDTH - 1 downto 8) <= (others => '0');
				phaseWBCtrl.sourceImm(7 downto 0) <= loadByteResult;
			when MIPS_CPU_INSTRUCTION_OPCODE_SH =>
				phaseWBCtrl.sourceImm <= storeHalfWordResult;
			when MIPS_CPU_INSTRUCTION_OPCODE_SB =>
				phaseWBCtrl.sourceImm <= storeByteResult;
			when others =>
				phaseWBCtrl.sourceImm <= phaseEXInput.sourceImm;
		end case;
		phaseWBCtrl.targetIsRAM <= phaseEXInput.targetIsRAM;
		phaseWBCtrl.targetIsReg <= phaseEXInput.targetIsReg;
		phaseWBCtrl.targetRAMAddr <= phaseEXInput.targetRAMAddr;
		if phaseExInput.instructionOpcode = MIPS_CPU_INSTRUCTION_OPCODE_SH or
		phaseExInput.instructionOpcode = MIPS_CPU_INSTRUCTION_OPCODE_SB then
			phaseWBCtrl.targetRegAddr <= (others => '0');
		else
			phaseWBCtrl.targetRegAddr <= phaseEXInput.targetRegAddr;
		end if;
		phaseWBCtrl.instructionOpcode <= phaseEXInput.instructionOpcode;
	end process;
	
	process(exceptionTrigger, phaseWBCtrl)
	begin
		if exceptionTrigger.enabled = FUNC_ENABLED then
			phaseWBCtrlOutput <= (
				sourceImm => (others => '0'),
				targetIsRAM => FUNC_DISABLED,
				targetIsReg => FUNC_DISABLED,
				targetRAMAddr => (others => '0'),
				targetRegAddr => (others => '0'),
				instructionOpcode => (others => '0')
			);
		else
			phaseWBCtrlOutput <= phaseWBCtrl;
		end if;
	end process;

	process(clock, reset)
	begin
		if reset = FUNC_ENABLED then
			--phaseWBCtrlOutput.targetIsReg <= FUNC_DISABLED;
			--phaseWBCtrlOutput.targetIsRAM <= FUNC_DISABLED;
		elsif rising_edge(clock) then
			exceptionTriggerOutput <= exceptionTrigger;
		end if;
	end process;
end Behavioral;
