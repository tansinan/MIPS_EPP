library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.MIPSCPU.all;

entity ALU is
	generic ( bit_length: integer := 32);
	port(
		number1 : in std_logic_vector(bit_length - 1 downto 0);
		number2 : in std_logic_vector(bit_length - 1 downto 0);
		operation : in std_logic_vector(ALU_OPERATION_CTRL_WIDTH - 1 downto 0);
		result : out std_logic_vector(bit_length - 1 downto 0)
	);
end ALU;


architecture Behavioral of ALU is
begin
	with operation select result <=
		number1 + number2 when ALU_OPERATION_ADD,
		number1 - number2 when ALU_OPERATION_SUBTRACT,
		number1 and number2 when ALU_OPERATION_LOGIC_AND,
		number1 or number2 when ALU_OPERATION_LOGIC_OR,
		(others => 'X') when others;
end Behavioral;