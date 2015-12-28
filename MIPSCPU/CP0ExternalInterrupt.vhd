library ieee;
use ieee.std_logic_1164.all;
use work.MIPSCPU.all;
use work.MIPSCP0.all;

entity CP0ExternalInterrupt_e is
	port
	(
		clock : in Clock_t;
		reset : in Reset_t;
		cp0RegisterFileData : in CP0RegisterFileOutput_t;
		interruptTriggerOutput : out CP0HardwareInterruptTrigger_t
	);
end CP0ExternalInterrupt_e;

architecture Behavioral of CP0ExternalInterrupt is
	signal interruptTrigger : CP0HardwareInterruptTrigger_t;
begin
	process(clock, reset)
	begin
		if reset = FUNC_ENABLED then
			interruptTrigger <= (
				enabled => FUNC_DISABLED,
				interruptCodeMask => (others => '0')
			);
		elsif rising_edge(clock) then
			interruptTrigger <= (
				enabled => FUNC_ENABLED,
				interruptCodeMask => "010000"
			);
		end if;
	end process;
	
	interruptTriggerOutput <= interruptTrigger;

end Behavioral;

