library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
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
end entity;


architecture Behavioral of ALU is
begin
	process(number1, number2, operation)
		variable shiftOperand : integer;
	begin
		shiftOperand := to_integer(unsigned(number2(4 downto 0)));
		case operation is
			when ALU_OPERATION_ADD =>
				result <= number1 + number2;
			when ALU_OPERATION_SUBTRACT =>
				result <= number1 - number2;
			when ALU_OPERATION_LOGIC_AND =>
				result <= number1 and number2;
			when ALU_OPERATION_LOGIC_OR =>
				result <= number1 or number2;
			when ALU_OPERATION_LOGIC_XOR =>
				result <= number1 xor number2;
			when ALU_OPERATION_EQUAL =>
				if number1 = number2 then
					result <= (0 => '1', others => '0');
				else
					result <= (others => '0');
				end if;
			when ALU_OPERATION_NOT_EQUAL =>
				if number1 = number2 then
					result <= (others => '0');
				else
					result <= (0 => '1', others => '0');
				end if;
			when ALU_OPERATION_LOGIC_NOR =>
				result <= number1 nor number2;
			when ALU_OPERATION_LESS_THAN_SIGNED =>
				if signed(number1) < signed(number2) then
					result <= (0 => '1', others => '0');
				else
					result <= (others => '0');
				end if;
			when ALU_OPERATION_LESS_THAN_UNSIGNED =>
				if unsigned(number1) < unsigned(number2) then
					result <= (0 => '1', others => '0');
				else
					result <= (others => '0');
				end if;
			when ALU_OPERATION_SHIFT_LEFT =>
				result <= std_logic_vector(unsigned(number1) sll shiftOperand);
			when ALU_OPERATION_SHIFT_RIGHT_LOGIC =>
				result <= std_logic_vector(unsigned(number1) srl shiftOperand);
			when ALU_OPERATION_SHIFT_RIGHT_ARITH =>
				result <= to_stdlogicvector(to_bitvector(number1) sra shiftOperand);
			when others =>
				result <= (others => 'X');
		end case;
	end process;
end architecture;
