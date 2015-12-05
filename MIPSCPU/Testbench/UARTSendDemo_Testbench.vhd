library ieee;
use ieee.std_logic_1164.all;
 
entity UARTSendDemo_Testbench is
end entity;
 
architecture behavior of UARTSendDemo_Testbench is 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    component UARTSendDemo
    port(
         clock : in  std_logic;
         reset : in  std_logic;
         clock_divided : out  std_logic;
         disp : out  std_logic;
         output : out  std_logic_vector(7 downto 0);
         rxd : in  std_logic;
         txd : out  std_logic
        );
    end component;
    

   --Inputs
   signal clock : std_logic := '0';
   signal reset : std_logic := '0';
   signal rxd : std_logic := '0';

 	--Outputs
   signal clock_divided : std_logic;
   signal disp : std_logic;
   signal output : std_logic_vector(7 downto 0);
   signal txd : std_logic;

   -- Clock period definitions
   constant clock_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: UARTSendDemo PORT MAP (
          clock => clock,
          reset => reset,
          clock_divided => clock_divided,
          disp => disp,
          output => output,
          rxd => rxd,
          txd => txd
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
      -- hold reset state for 100 ns.
	  reset <= '0';
      wait for clock_period* 2;
	  reset <= '1';

      wait for clock_period*10;

      -- insert stimulus here 

      wait;
   end process;

end architecture;
