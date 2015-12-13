library ieee;
use ieee.std_logic_1164.all;

entity HighLatencyMathIPCoreWrapper is
	port
	(
		number1 : in CPUData_t;
		number1Signed : in EnablingControl_t;
		number2 : in CPUData_t;
		number2Signed : in EnablingControl_t;
		resultReady : out ReadyStatus_t;
		output : out CPUDoubleWordData_t
	);
end entity;

architecture Behavioral of HighLatencyMathIPCoreWrapper is
begin

end architecture;
