LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
entity HighLatencyMathIPCoreWrapper_Testbench is
end entity;
 
architecture behavior of HighLatencyMathIPCoreWrapper_Testbench is 
    

   --Inputs
   signal reset : std_logic := '0';
   signal clock : std_logic := '0';
   signal number1 : std_logic_vector(31 downto 0) := (others => '0');
   signal number1Signed : std_logic := '0';
   signal number2 : std_logic_vector(31 downto 0) := (others => '0');
   signal number2Signed : std_logic := '0';

 	--Outputs
   signal resultReady : std_logic;
   signal output : std_logic_vector(31 downto 0);

   -- Clock period definitions
   constant clock_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: entity work.HighLatencyMathIPCoreWrapper port map (
          reset => reset,
          clock => clock,
          number1 => number1,
          number1Signed => number1Signed,
          number2 => number2,
          number2Signed => number2Signed,
          resultReady => resultReady,
          output => output
        );

   -- Clock process definitions
   clock_process :process
   begin
		clock <= '0';
		wait for clock_period/2;
		clock <= '1';
		wait for clock_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin
	  reset <= '0';
      -- hold reset state for 100 ns.
      wait for 100 ns;
	  reset <= '1';

      wait for clock_period*10;

	number1 <= "00000000000000000000000000001010";
	number2 <= "00000000000000000000000000011010";
      -- insert stimulus here 

      wait;
   end process;

end;
