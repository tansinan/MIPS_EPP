library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.MIPSCPU.all;

entity RegisterFileWriter is
    port (
		write_select : in std_logic_vector(MIPS_CPU_REGISTER_ADDRESS_WIDTH - 1 downto 0);
		write_data : in std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
		operation_output : out std_logic_vector(MIPS_CPU_REGISTER_COUNT - 1 downto 0);
		data_output : out std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0)
	);
end RegisterFileWriter;

architecture Behavioral of RegisterFileWriter is
begin
	operation_output <= (others => REGISTER_OPERATION_READ);
	operation_output(to_integer(unsigned(write_select))) <= REGISTER_OPERATION_WRITE;
	data_output <= write_data;
end Behavioral;