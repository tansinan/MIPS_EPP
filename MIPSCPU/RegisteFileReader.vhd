library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.MIPSCPU.all;

entity RegisterFileReader is
    port (
		register_file_output : in mips_register_file_port;
		read_select_1 : in std_logic_vector (MIPS_CPU_REGISTER_ADDRESS_WIDTH - 1 downto 0);
		read_select_2 : in std_logic_vector (MIPS_CPU_REGISTER_ADDRESS_WIDTH - 1 downto 0);
		read_result_1 : out std_logic_vector (MIPS_CPU_DATA_WIDTH - 1 downto 0);
		read_result_2 : out std_logic_vector (MIPS_CPU_DATA_WIDTH - 1 downto 0)
	);
end entity;

architecture Behavioral of RegisterFileReader is
begin
	read_result_1 <= register_file_output(to_integer(unsigned(read_select_1)));
	read_result_2 <= register_file_output(to_integer(unsigned(read_select_2)));
end architecture;