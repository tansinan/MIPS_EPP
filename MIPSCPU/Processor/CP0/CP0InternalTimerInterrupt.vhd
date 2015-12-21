library ieee;
use ieee.std_logic_1164.all;
use work.MIPSCPU.all;
use work.MIPSCP0.all;

entity CP0InternalTimerInterrupt_e is
	port
	(
		clock : in Clock_t;
		reset : in Reset_t;
		compareRegisterModifiedReset : in EnablingControl_t;
		cp0RegisterFileData : in CP0RegisterFileOutput_t;
		interruptTriggerOutput : out CP0HardwareInterruptTrigger_t
	);
end entity;

architecture Behavioral of CP0InternalTimerInterrupt_e is
	signal interruptTrigger : CP0HardwareInterruptTrigger_t;
begin
	process(clock, reset)
	begin
		if reset = FUNC_ENABLED then
			-- No interrupt is triggered on reset.
			interruptTrigger <= (
				enabled => FUNC_DISABLED,
				interruptCodeMask => (others => '0')
			);
		elsif rising_edge(clock) then
			-- When CP0 compare register is modified, interrupt will stop
			-- being triggered.
			if compareRegisterModifiedReset = FUNC_ENABLED then
				interruptTrigger <= (
					enabled => FUNC_DISABLED,
					interruptCodeMask => (others => '0')
				);
				
			-- Otherwise, once the interrupt is triggered, it will be triggered
			-- over and over again, though EXL bit could mask it temporarily.
			elsif cp0RegisterFileData(MIPS_CP0_REGISTER_INDEX_COUNT) =
			cp0RegisterFileData(MIPS_CP0_REGISTER_INDEX_COMPARE) then
				interruptTrigger <= (
					enabled => FUNC_ENABLED,
					-- Timer interrupt always use IRQ 5
					interruptCodeMask => "100000"
				);
			end if;
		end if;
	end process;
	
	interruptTriggerOutput <= interruptTrigger;

end architecture;
