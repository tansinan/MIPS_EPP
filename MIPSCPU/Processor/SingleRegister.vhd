library ieee;
use ieee.std_logic_1164.all;
use work.MIPSCPU.all;

entity SingleRegister is
	generic (
		initialValue : CPUData_t := (others => '0')
	);
	port ( 
		reset : in Reset_t;
		clock : in Clock_t;
		input : in CPUData_t;
		operation : in std_logic;
		output : out CPUData_t
	);
end entity;

architecture Behavioral of SingleRegister is
	signal data : CPUData_t;
begin
	Register_Process : process (clock, reset)
	begin
		if reset = '0' then
			data <= initialValue;
		elsif rising_edge(clock) then
			if operation = REGISTER_OPERATION_WRITE then
				data <= input;
			end if;
		end if;
	end process;
	output <= data;
end architecture;
