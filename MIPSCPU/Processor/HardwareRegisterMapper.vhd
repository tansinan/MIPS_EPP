library ieee;
use ieee.std_logic_1164.all;

entity HardwareRegisterMapper is
	port
	(
		clock : in std_logic;
		reset : in std_logic;
		readControl1 : in RAMReadControl_t;
		readControl2 : in RAMReadControl_t;
		writeControl : in RAMWriteControl_t;
		result : out std_logic_vector(PHYSICS_RAM_DATA_WIDTH - 1 downto 0)
	);
end entity;

architecture Behavioral of HardwareRegisterMapper is
begin


end architecture;

