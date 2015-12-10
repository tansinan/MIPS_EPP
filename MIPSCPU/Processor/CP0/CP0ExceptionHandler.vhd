library ieee;
use ieee.std_logic_1164.all;
use work.MIPSCPU.all;
use work.MIPSCP0.all;

entity CP0ExceptionHandler is
	port
	(
		clock : in Clock_t;
		reset : in Reset_t;
		exceptionTrigger : in CP0ExceptionTrigger_t;
		pcValue : in CPUData_t;
		pcOverrideControl : out RegisterControl_t;
		exceptionPipelineClear : out EnablingControl_t
	);
end entity;

architecture Behavioral of CP0ExceptionHandler is
begin
	process(clock, reset)
	begin
		if reset = FUNC_ENABLED then
			pcOverrideControl.operation <= REGISTER_OPERATION_READ;
		elsif rising_edge(clock) then
			if exceptionTrigger.enabled = FUNC_ENABLED then
				pcOverrideControl.operation <= REGISTER_OPERATION_WRITE;
				pcOverrideControl.data <= MIPS_CP0_NONBOOT_EXCEPTION_HANDLER;
				exceptionPipelineClear <= FUNC_ENABLED;
				report "Debug : Exception triggered, pipeline will be cleared.";
			else
				pcOverrideControl.operation <= REGISTER_OPERATION_READ;
				pcOverrideControl.data <= (others => '0');
				exceptionPipelineClear <= FUNC_DISABLED;
			end if;
		end if;
	end process;
end architecture;
