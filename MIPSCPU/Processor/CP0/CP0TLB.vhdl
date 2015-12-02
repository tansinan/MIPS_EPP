library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.MIPSCPU.all;
use work.MIPSCP0.all;

entity CP0TLB_c is
    Port (
		reset : in std_logic;
		clock : in std_logic;
        control: in CP0TLBControl_t;
		output : out CP0TLBData_t
	);
end entity;

architecture Behavioral of CP0TLB_c is
	signal tlbData : CP0TLBData_t;
begin
	process(clock, reset)
	begin
		if reset = FUNC_ENABLED then
			-- TODO : refer to MIPS Specification to know if any thing needs to be done.
		elsif rising_edge(clock) then
			if control.writeEnabled = FUNC_ENABLED then
				tlbData(to_integer(unsigned(control.index))) <= control.data;
			end if;
		end if;
	end process;
	output <= tlbData;
end architecture;
