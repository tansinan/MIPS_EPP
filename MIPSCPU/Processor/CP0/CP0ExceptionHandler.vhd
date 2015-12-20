library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.MIPSCPU.all;
use work.MIPSCP0.all;

entity CP0ExceptionHandler is
	port
	(
		clock : in Clock_t;
		reset : in Reset_t;
		exceptionTrigger : in CP0ExceptionTrigger_t;
		interruptTriggerArray : in CP0HardwareInterruptTriggerArray_t;
		pcValue : in CPUData_t;
		pcOverrideControl : out RegisterControl_t;
		exceptionPipelineClear : out EnablingControl_t;
		cp0RegisterFileData : in CP0RegisterFileOutput_t;
		cp0RegisterFileControl : out CP0RegisterFileControl_t
	);
end entity;

architecture Behavioral of CP0ExceptionHandler is
begin
	process(clock, reset)
		variable newCP0CauseRegister : CPUData_t;
		variable newCP0StatusRegister : CPUData_t;
		variable haveInterrupt : boolean;
	begin
		-- TODO : CP0 behaviour on EXL set is different!
		if reset = FUNC_ENABLED then
			for i in 0 to MIPS_CP0_REGISTER_COUNT - 1 loop
				cp0RegisterFileControl(i) <= (
					operation => REGISTER_OPERATION_READ,
					data => (others => '0')
				);
			end loop;
			pcOverrideControl.operation <= REGISTER_OPERATION_READ;
		elsif rising_edge(clock) then
			pcOverrideControl.operation <= REGISTER_OPERATION_READ;
			pcOverrideControl.data <= (others => '0');
			exceptionPipelineClear <= FUNC_DISABLED;
			for i in 0 to MIPS_CP0_REGISTER_COUNT - 1 loop
				cp0RegisterFileControl(i) <= (
					operation => REGISTER_OPERATION_READ,
					data => (others => '0')
				);
			end loop;
			newCP0CauseRegister := cp0RegisterFileData(MIPS_CP0_REGISTER_INDEX_CAUSE);
			newCP0StatusRegister := cp0RegisterFileData(MIPS_CP0_REGISTER_INDEX_STATUS);
			haveInterrupt := false;
			if exceptionTrigger.enabled = FUNC_ENABLED then
				pcOverrideControl.operation <= REGISTER_OPERATION_WRITE;
				pcOverrideControl.data <= MIPS_CP0_NONBOOT_EXCEPTION_HANDLER;
				exceptionPipelineClear <= FUNC_ENABLED;
				cp0RegisterFileControl(MIPS_CP0_REGISTER_INDEX_EPC) <= (
					operation => REGISTER_OPERATION_WRITE,
					data => pcValue - 4
				);
				newCP0CauseRegister(MIPS_CP0_CAUSE_EXCEPTION_CODE_HI downto MIPS_CP0_CAUSE_EXCEPTION_CODE_LO)
					:= exceptionTrigger.exceptionCode;
				-- TODO : currently we don't implement any reset/cache/NMI, so it is always EXL to
				-- be set. if those features are added in the future, this need to be changed!
				newCP0StatusRegister(MIPS_CP0_STATUS_EXL) := '1';
				cp0RegisterFileControl(MIPS_CP0_REGISTER_INDEX_EPC) <= (
					operation => REGISTER_OPERATION_WRITE,
					data => pcValue
				);
				cp0RegisterFileControl(MIPS_CP0_REGISTER_INDEX_CAUSE) <= (
					operation => REGISTER_OPERATION_WRITE,
					data => newCP0CauseRegister
				);
				cp0RegisterFileControl(MIPS_CP0_REGISTER_INDEX_STATUS) <= (
					operation => REGISTER_OPERATION_WRITE,
					data => newCP0StatusRegister
				);
			else
				-- TODO : This should be changed to consider interrupt priority!
				for i in 0 to MIPS_CP0_REGISTER_COUNT - 1 loop
					if interruptTriggerArray(i).enabled = FUNC_ENABLED and
					haveInterrupt = false then
						haveInterrupt := true;
						exceptionPipelineClear <= FUNC_ENABLED;
						newCP0StatusRegister(MIPS_CP0_STATUS_EXL) := '1';
						newCP0StatusRegister(
							MIPS_CP0_CAUSE_INTERRUPT_PENDING_HI downto MIPS_CP0_CAUSE_INTERRUPT_PENDING_LO)
						:= interruptTriggerArray(i).interruptCodeMask;
						cp0RegisterFileControl(MIPS_CP0_REGISTER_INDEX_EPC) <= (
							operation => REGISTER_OPERATION_WRITE,
							data => pcValue
						);
						cp0RegisterFileControl(MIPS_CP0_REGISTER_INDEX_CAUSE) <= (
							operation => REGISTER_OPERATION_WRITE,
							data => newCP0CauseRegister
						);
						cp0RegisterFileControl(MIPS_CP0_REGISTER_INDEX_STATUS) <= (
							operation => REGISTER_OPERATION_WRITE,
							data => newCP0StatusRegister
						);
					end if;
				end loop;
			end if;
		end if;
	end process;
end architecture;
