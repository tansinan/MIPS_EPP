library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.MIPSCPU.all;

entity CountRegister is
	generic (
		width : integer := MIPS_CPU_DATA_WIDTH
	);
	port ( 
		reset : in std_logic;
		clock : in std_logic;
		input : in  std_logic_vector (width - 1 downto 0);
		operation : in  std_logic;
		output : out  std_logic_vector (width - 1 downto 0)
	);
end entity;

architecture Behavioral of CountRegister is
	signal data : std_logic_vector (width - 1 downto 0);
begin
	process (clock, reset)
	begin
		if reset = '0' then
			data <= (others => '0');
		elsif rising_edge(clock) then
			if operation = REGISTER_OPERATION_WRITE then
				data <= input;
			else
				data <= data + 1;
			end if;
		end if;
	end process;
	
	process(data)
	begin
		output <= data;
	end process;
	
end architecture;
