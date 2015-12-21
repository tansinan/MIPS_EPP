library ieee;
use ieee.std_logic_1164.all;
use work.MIPSCPU.all;
use work.MIPSCP0.all;

entity CP0InternalTimerInterrupt_e is
	port
	(
		cp0RegisterFileData : in CP0RegisterFileOutput_t;
		interruptTrigger : out CP0HardwareInterruptTrigger_t
	);
end entity;

architecture Behavioral of CP0InternalTimerInterrupt_e is
begin
	process(cp0RegisterFileData)
	begin
		if cp0RegisterFileData(MIPS_CP0_REGISTER_INDEX_COUNT) =
		cp0RegisterFileData(MIPS_CP0_REGISTER_INDEX_COMPARE) then
			interruptTrigger <= (
				enabled => FUNC_ENABLED,
				interruptCodeMask => "100000" -- TIMER interrupt always use 5
			);
		else
			interruptTrigger <= (
				enabled => FUNC_DISABLED,
				interruptCodeMask => (others => '0')
			);
		end if;
	end process;

end architecture;
