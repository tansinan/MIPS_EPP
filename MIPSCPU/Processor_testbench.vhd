library ieee;
use ieee.std_logic_1164.all;
use work.MIPSCPU.all;
 
-- uncomment the following library declaration if using
-- arithmetic functions with signed or unsigned values
--use ieee.numeric_std.all;
 
entity Processor_Testbench is
end Processor_Testbench;

architecture behavior of Processor_Testbench is 

	-- component declaration for the unit under test (uut)

	component Processor is
		port (
			reset : in std_logic;
			clock : in std_logic;
			instruction : in std_logic_vector(MIPS_CPU_INSTRUCTION_WIDTH - 1 downto 0);
			register_file_debug : out mips_register_file_port
		);
	end component;
    

   --inputs
   signal reset : std_logic := '0';
   signal clock : std_logic := '0';
   signal instruction : std_logic_vector(MIPS_CPU_INSTRUCTION_WIDTH - 1 downto 0);

 	--outputs
   signal register_file_debug : mips_register_file_port;
   	signal current_test_success : boolean;

   -- clock period definitions
   constant clock_period : time := 20 ns;
 
begin
 
	-- instantiate the unit under test (uut)
	uut: Processor port map (
		reset => reset,
		clock => clock,
		instruction => instruction,
		register_file_debug => register_file_debug
	);

   -- clock process definitions
   clock_process : process
   begin
		clock <= '0';
		wait for clock_period/2;
		clock <= '1';
		wait for clock_period/2;
   end process;
 

   -- stimulus process
   stim_proc: process
   begin
		reset <= '0';
		wait for clock_period * 8;

		current_test_success <= true;
		reset <= '1';
		instruction <= "00100100000000010000000000000100";
		wait for clock_period * 4;
		
		if current_test_success = true then
			if register_file_debug(0) /= "00000000000000000000000000000000" then
				report "Test case 1 failed";
			end if;
		end if;
		if current_test_success = true then
			if register_file_debug(1) /= "00000000000000000000000000000100" then
				report "Test case 1 failed";
			end if;
		end if;
		if current_test_success = true then
			report "Test case 1 succeeded";
		end if;
		
		reset <= '1';
		instruction <= "00100100001000010000000000000010";
		wait for clock_period * 4;
		
		if current_test_success = true then
			if register_file_debug(0) /= "00000000000000000000000000000000" then
				report "Test case 1 failed";
			end if;
		end if;
		if current_test_success = true then
			if register_file_debug(1) /= "00000000000000000000000000000110" then
				report "Test case 1 failed";
			end if;
		end if;
		if current_test_success = true then
			report "Test case 1 succeeded";
		end if;
		
		
		
		reset <= '1';
		instruction <= MIPS_CPU_INSTRUCTION_NOP;
		wait for clock_period * 4;
		
		wait;

   end process;
end;
