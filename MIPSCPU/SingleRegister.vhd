library ieee;
use ieee.std_logic_1164.all;
use work.MIPSCPU.all;

entity SingleRegister is
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

architecture Behavioral of SingleRegister is
	signal data : std_logic_vector (width - 1 downto 0);
begin
	Register_Process : process (clock, reset)
	begin
	if reset = '0' then
		data <= (others => '0');
		output <= (others => '0');
	elsif rising_edge(clock) then
		if operation = REGISTER_OPERATION_WRITE then
			data <= input;
			output <= input;
		else
			data <= data;
			output <= data;
		end if;
	end if;
	end process;
end architecture;

