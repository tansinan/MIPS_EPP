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
		internalInterruptSource : in CP0InternalInterruptSource_t;
		externalInterruptSource : in CP0ExternalInterruptSource_t;
		pcValue : in CPUData_t;
		exceptionPCValue : in CPUData_t;
		pcOverrideControl : out RegisterControl_t;
		exceptionPipelineClear : out EnablingControl_t;
		cp0RegisterFileData : in CP0RegisterFileOutput_t;
		cp0RegisterFileControl : out CP0RegisterFileControl_t
	);
end entity;

architecture Behavioral of CP0ExceptionHandler is
	signal interruptSource : CP0InterruptSource_t;
begin
	process(internalInterruptSource, externalInterruptSource)
	begin
		for i in 0 to MIPS_CP0_EXTERNAL_INTERRUPT_SOURCE_COUNT - 1 loop
			interruptSource(i) <= externalInterruptSource(i);
		end loop;
		for i in 0 to MIPS_CP0_INTERNAL_INTERRUPT_SOURCE_COUNT - 1 loop
			interruptSource(i + MIPS_CP0_EXTERNAL_INTERRUPT_SOURCE_COUNT)
				<= internalInterruptSource(i);
		end loop;
	end process;
	
	process(clock, reset)
		variable newCP0CauseRegister : CPUData_t;
		variable newCP0StatusRegister : CPUData_t;
		variable newCP0EntryHiRegister : CPUData_t;
		variable generalExceptionHandlerAddress : CPUData_t;
		variable tlbRefillExceptionHandlerAddress : CPUData_t;
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
			exceptionPipelineClear <= FUNC_DISABLED;
		elsif rising_edge(clock) then
			generalExceptionHandlerAddress :=
				cp0RegisterFileData(MIPS_CP0_REGISTER_INDEX_EXCEPTION_VECTOR_BASE) or
				MIPS_CP0_NONBOOT_GENERAL_EXCEPTION_HANDLER;
			tlbRefillExceptionHandlerAddress :=
				cp0RegisterFileData(MIPS_CP0_REGISTER_INDEX_EXCEPTION_VECTOR_BASE) or
				MIPS_CP0_NONBOOT_TLB_REFILL_EXCEPTION_HANDLER;
			-- Let nothing to be done on the beginning of the process.
			pcOverrideControl <= (
				operation => REGISTER_OPERATION_READ,
				data => (others => '0')
			);
			exceptionPipelineClear <= FUNC_DISABLED;
			for i in 0 to MIPS_CP0_REGISTER_COUNT - 1 loop
				cp0RegisterFileControl(i) <= (
					operation => REGISTER_OPERATION_READ,
					data => (others => '0')
				);
			end loop;
			newCP0CauseRegister := cp0RegisterFileData(MIPS_CP0_REGISTER_INDEX_CAUSE);
			newCP0StatusRegister := cp0RegisterFileData(MIPS_CP0_REGISTER_INDEX_STATUS);
			newCP0EntryHiRegister := cp0RegisterFileData(MIPS_CP0_REGISTER_INDEX_TLB_ENTRY_HIGH);
			haveInterrupt := false;
			
			-- Since we don't really implement things like reset/NMI, exception will
			-- have a higher priority over interrupts.
			if exceptionTrigger.enabled = FUNC_ENABLED then
				
				-- TLB Refill exception may use a special exception vector.
				if exceptionTrigger.isTLBRefill = FUNC_ENABLED then
					pcOverrideControl <= (
						operation => REGISTER_OPERATION_WRITE,
						data => generalExceptionHandlerAddress
					);
				else
					pcOverrideControl <= (
						operation => REGISTER_OPERATION_WRITE,
						data => generalExceptionHandlerAddress
					);
				end if;
				exceptionPipelineClear <= FUNC_ENABLED;
				if exceptionTrigger.exceptionCode = MIPS_CP0_CAUSE_EXCEPTION_CODE_TLB_MODIFICATION
				or exceptionTrigger.exceptionCode = MIPS_CP0_CAUSE_EXCEPTION_CODE_TLB_LOAD
				or exceptionTrigger.exceptionCode = MIPS_CP0_CAUSE_EXCEPTION_CODE_TLB_STORE then
					newCP0EntryHiRegister(MIPS_CP0_REGISTER_ENTRY_HIGH_VPN2_HI downto MIPS_CP0_REGISTER_ENTRY_HIGH_VPN2_LO) :=
					exceptionTrigger.badVirtualAddress(MIPS_CP0_REGISTER_ENTRY_HIGH_VPN2_HI downto MIPS_CP0_REGISTER_ENTRY_HIGH_VPN2_LO);
				end if;
				newCP0CauseRegister(MIPS_CP0_CAUSE_EXCEPTION_CODE_HI downto MIPS_CP0_CAUSE_EXCEPTION_CODE_LO)
					:= exceptionTrigger.exceptionCode;
				-- TODO : currently we don't implement any reset/cache/NMI, so it is always EXL to
				-- be set. if those features are added in the future, this need to be changed!
				newCP0StatusRegister(MIPS_CP0_STATUS_EXL) := '1';
				cp0RegisterFileControl(MIPS_CP0_REGISTER_INDEX_EPC) <= (
					operation => REGISTER_OPERATION_WRITE,
					data => exceptionPCValue
				);
				cp0RegisterFileControl(MIPS_CP0_REGISTER_INDEX_CAUSE) <= (
					operation => REGISTER_OPERATION_WRITE,
					data => newCP0CauseRegister
				);
				cp0RegisterFileControl(MIPS_CP0_REGISTER_INDEX_STATUS) <= (
					operation => REGISTER_OPERATION_WRITE,
					data => newCP0StatusRegister
				);
				cp0RegisterFileControl(MIPS_CP0_REGISTER_INDEX_TLB_ENTRY_HIGH) <= (
					operation => REGISTER_OPERATION_WRITE,
					data => newCP0EntryHiRegister
				);
			-- If no exceptions happens, check interrupts.
			else
				-- If global interrupt is enabled, interrupts will be checked.
				if cp0RegisterFileData(MIPS_CP0_REGISTER_INDEX_STATUS)(MIPS_CP0_STATUS_IE) = '1'
				and cp0RegisterFileData(MIPS_CP0_REGISTER_INDEX_STATUS)(MIPS_CP0_STATUS_ERL) = '0'
				and cp0RegisterFileData(MIPS_CP0_REGISTER_INDEX_STATUS)(MIPS_CP0_STATUS_EXL) = '0'
				then
					for i in 0 to MIPS_CP0_INTERRUPT_SOURCE_COUNT - 1 loop
						if interruptSource(i).enabled = FUNC_ENABLED
						and haveInterrupt = false then
							haveInterrupt := true;
							exceptionPipelineClear <= FUNC_ENABLED;
							newCP0StatusRegister(MIPS_CP0_STATUS_EXL) := '1';
							newCP0CauseRegister(
								MIPS_CP0_CAUSE_INTERRUPT_PENDING_HI downto MIPS_CP0_CAUSE_INTERRUPT_PENDING_LO)
							:= interruptSource(i).interruptCodeMask;
							cp0RegisterFileControl(MIPS_CP0_REGISTER_INDEX_EPC) <= (
								operation => REGISTER_OPERATION_WRITE,
								data => exceptionPCValue
							);
							cp0RegisterFileControl(MIPS_CP0_REGISTER_INDEX_CAUSE) <= (
								operation => REGISTER_OPERATION_WRITE,
								data => newCP0CauseRegister
							);
							cp0RegisterFileControl(MIPS_CP0_REGISTER_INDEX_STATUS) <= (
								operation => REGISTER_OPERATION_WRITE,
								data => newCP0StatusRegister
							);
							pcOverrideControl.operation <= REGISTER_OPERATION_WRITE;
							pcOverrideControl.data <= generalExceptionHandlerAddress;
						end if;
					end loop;
				end if;
			end if;
		end if;
	end process;
end architecture;
