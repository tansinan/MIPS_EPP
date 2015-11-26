library ieee;
use ieee.std_logic_1164.all;
use work.MIPSCPU.all;
 
entity alu_testbench is
	constant ALU_TEST_WIDTH : integer := 4;
end alu_testbench;
 
architecture behavior of alu_testbench is 

	component alu
		generic ( bit_length: integer := 32);
		port(
			number1 : in std_logic_vector(bit_length - 1 downto 0);
			number2 : in std_logic_vector(bit_length - 1 downto 0);
			operation : in std_logic_vector(ALU_OPERATION_CTRL_WIDTH - 1 downto 0);
			result : out std_logic_vector(bit_length - 1 downto 0)
		);
    end component;

	signal number1 : std_logic_vector(ALU_TEST_WIDTH - 1 downto 0) := (others => '0');
	signal number2 : std_logic_vector(ALU_TEST_WIDTH - 1 downto 0) := (others => '0');
	signal operation : std_logic_vector(ALU_OPERATION_CTRL_WIDTH - 1 downto 0) := (others => '0');
	signal result : std_logic_vector(ALU_TEST_WIDTH - 1 downto 0);

	constant time_delay : time := 10 ns;
 
begin
 
	-- instantiate the unit under test (uut)
   uut: alu generic map ( bit_length => 4 ) port map (
          number1 => number1,
          number2 => number2,
          operation => operation,
          result => result
        );

   -- stimulus process
	stim_proc: process
	begin
		wait for time_delay;
		report "Testing VHDL module ALU...";
		report "Testing ALU_OPERATION_ADD...";
		operation <= ALU_OPERATION_ADD;
		number1 <= "1111";
		number2 <= "1111";
		wait for time_delay;
		
		if result = "1110" then
			report "Test case 1 passed";
		else
			report "Test case 1 failed";
		end if;
		
		report "Testing ALU_OPERATION_SUBTRACT...";
		operation <= ALU_OPERATION_SUBTRACT;
		number1 <= "1010";
		number2 <= "0101";
		wait for time_delay;
		if result = "0101" then
			report "Test case 2 passed";
		else
			report "Test case 2 failed";
		end if;
		
		report "Testing ALU_OPERATION_LOGIC_AND...";
		operation <= ALU_OPERATION_LOGIC_AND;
		number1 <= "1100";
		number2 <= "1010";
		wait for time_delay;
		if result = "1000" then
			report "Test case 3 passed";
		else
			report "Test case 3 failed";
		end if;
		
		report "Testing ALU_OPERATION_LOGIC_OR...";
		operation <= ALU_OPERATION_LOGIC_OR;
		number1 <= "1100";
		number2 <= "1010";
		wait for time_delay;
		if result = "1110" then
			report "Test case 4 passed";
		else
			report "Test case 4 failed";
		end if;
		
		report "Testing ALU_OPERATION_LESS_THAN_SIGNED...";
		operation <= ALU_OPERATION_LESS_THAN_SIGNED;
		number1 <= "1100";
		number2 <= "1010";
		wait for time_delay;
		if result = "0000" then
			report "Test case 5 passed";
		else
			report "Test case 5 failed";
		end if;
		
		number1 <= "1000";
		number2 <= "1010";
		wait for time_delay;
		if result = "0001" then
			report "Test case 6 passed";
		else
			report "Test case 6 failed";
		end if;
		
		number1 <= "0001";
		number2 <= "0110";
		wait for time_delay;
		if result = "0001" then
			report "Test case 7 passed";
		else
			report "Test case 7 failed";
		end if;
		
		number1 <= "1001";
		number2 <= "0110";
		wait for time_delay;
		if result = "0001" then
			report "Test case 8 passed";
		else
			report "Test case 8 failed";
		end if;
		
		report "Testing ALU_OPERATION_LESS_THAN_UNSIGNED...";
		operation <= ALU_OPERATION_LESS_THAN_UNSIGNED;
		number1 <= "1100";
		number2 <= "1010";
		wait for time_delay;
		if result = "0000" then
			report "Test case 9 passed";
		else
			report "Test case 9 failed";
		end if;
		
		number1 <= "1000";
		number2 <= "1010";
		wait for time_delay;
		if result = "0001" then
			report "Test case 10 passed";
		else
			report "Test case 10 failed";
		end if;
		
		number1 <= "0001";
		number2 <= "0110";
		wait for time_delay;
		if result = "0001" then
			report "Test case 11 passed";
		else
			report "Test case 11 failed";
		end if;
		
		number1 <= "1001";
		number2 <= "0110";
		wait for time_delay;
		if result = "0000" then
			report "Test case 12 passed";
		else
			report "Test case 12 failed";
		end if;

		report "Testing ALU_OPERATION_SHIFT_LEFT...";
		operation <= ALU_OPERATION_SHIFT_LEFT;
		number1 <= "1110";
		number2 <= "0010";
		wait for time_delay;
		if result = "1000" then
			report "Test case 13 passed";
		else
			report "Test case 13 failed";
		end if;
		
		report "Testing ALU_OPERATION_SHIFT_RIGHT_LOGIC...";
		operation <= ALU_OPERATION_SHIFT_RIGHT_LOGIC;
		number1 <= "1100";
		number2 <= "0001";
		wait for time_delay;
		if result = "0110" then
			report "Test case 14 passed";
		else
			report "Test case 14 failed";
		end if;
		
		report "Testing ALU_OPERATION_SHIFT_RIGHT_ARITH...";
		operation <= ALU_OPERATION_SHIFT_RIGHT_ARITH;
		number1 <= "1100";
		number2 <= "0001";
		wait for time_delay;
		if result = "1110" then
			report "Test case 15 passed";
		else
			report "Test case 15 failed";
		end if;
		
		wait;
	end process;
end;
