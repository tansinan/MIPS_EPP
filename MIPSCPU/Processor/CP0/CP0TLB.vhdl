library ieee;
use ieee.std_logic_1164.all;
use work.MIPSCPU.all;
use work.MIPSCP0.all;

entity CP0TLB_c is
    Port (
		reset : in std_logic;
		clock : in std_logic;
        control: in CP0TLBControl_t;
		output : out CP0TLBOutput_t
	);
end entity;

architecture Behavioral of CP0TLB_c is
end architecture;
