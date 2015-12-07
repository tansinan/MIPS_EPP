library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library MIPSEPP;
use MIPSEPP.Common.all;

entity ClockDivider is
	port
	(
		clockIn : in Clock_t;
		reset : in Reset_t;
		clockOut : out Clock_t
	);
end ClockDivider;

architecture Behavioral of ClockDivider is
	signal counter : std_logic_vector(1 downto 0);
begin
	process(clockIn, reset)
	begin
		counter <= counter + 1;
	end process;
	clockOut <= counter(1);
end Behavioral;

