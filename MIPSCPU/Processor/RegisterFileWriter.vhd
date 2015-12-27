library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.MIPSCPU.all;

entity RegisterFileWriter is
  port (
		control1 : in RegisterFileControl_t;
		control2 : in RegisterFileControl_t;
		control3 : in RegisterFileControl_t;
		operation_output : out std_logic_vector(MIPS_CPU_REGISTER_COUNT - 1 downto 0);
		data_output : out std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0)
	);
end entity;

architecture Behavioral of RegisterFileWriter is
begin
	process(control1, control2, control3)
		variable validControl : RegisterFileControl_t;
	begin
		if control1.address /= "00000" then
			validControl := control1;
		elsif control2.address /= "00000" then
			validControl := control2;
		else
			validControl := control3;
		end if;

		for i in 0 to MIPS_CPU_REGISTER_COUNT - 1 loop
			if i = to_integer(unsigned(validControl.address)) then
				operation_output(i) <= '1';
			else
				operation_output(i) <= '0';
			end if;
		end loop;
		data_output <= validControl.data;
	end process;
end Behavioral;
