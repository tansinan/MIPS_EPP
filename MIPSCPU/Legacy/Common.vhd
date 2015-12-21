library ieee;
use ieee.std_logic_1164.all;

package Common is

	-- Define clock, reset and enable/disable control related constants and subtypes.
	subtype Clock_t is std_logic;
	subtype Reset_t is std_logic;
	subtype EnablingControl_t is std_logic;
	constant FUNC_ENABLED : std_logic := '0';
	constant FUNC_DISABLED : std_logic := '1';

end package;

package body Common is

end Common;
