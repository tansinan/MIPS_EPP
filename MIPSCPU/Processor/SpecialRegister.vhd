library ieee;
use ieee.std_logic_1164.all;
use work.MIPSCPU.all;

entity SpecialRegister is
	port (
		reset : in std_logic;
		clock : in std_logic;
        control1 : in RegisterControl_t;
        control2 : in RegisterControl_t;
        control3 : in RegisterControl_t;
        output : out std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0)
	);
end entity;

architecture Behavioral of SpecialRegister is
	signal data : std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
begin
	Register_Process : process (clock, reset)
	begin
	if reset = '0' then
		data <= (others => '0');
		output <= (others => '0');
	elsif rising_edge(clock) then
        if control1.operation = REGISTER_OPERATION_WRITE then
            data <= control1.data;
            output <= control1.data;
        elsif control2.operation = REGISTER_OPERATION_WRITE then
            data <= control2.data;
            output <= control2.data;
        elsif control3.operation = REGISTER_OPERATION_WRITE then
            data <= control3.data;
            output <= control3.data;
		else
			data <= data;
			output <= data;
		end if;
	end if;
	end process;
end architecture;
