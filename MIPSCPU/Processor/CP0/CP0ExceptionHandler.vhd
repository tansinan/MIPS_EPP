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
		pcControl : in RegisterControl_t;
		exceptionPipelineFlush : out EnablingControl_t
	);
end entity;

architecture Behavioral of CP0ExceptionHandler is
begin
	process(clock, reset)
	begin
		if reset = FUNC_ENABLED then
			pcContorl.operation <= REGISTER_OPERATION_READ;
		elsif rising_edge(clock) then
		end if;
	end process;
end Behavioral;

