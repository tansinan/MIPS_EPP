library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.MIPSCPU.all;

entity ClockDivider_e is
	port
	(
		clockIn : in Clock_t;
		reset : in Reset_t;
		clockOut : out Clock_t
	);
end entity;

architecture Behavioral of ClockDivider_e is
	signal counter : std_logic_vector(1 downto 0);
begin
	process(clockIn, reset)
	begin
		if reset = FUNC_ENABLED then
			counter <= (others => '0');
		elsif rising_edge(clockIn) then
			counter <= counter + 1;
		end if;
	end process;
	clockOut <= counter(0);
end architecture;

