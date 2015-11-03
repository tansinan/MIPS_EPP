library ieee;
use ieee.std_logic_1164.all;
 
-- uncomment the following library declaration if using
-- arithmetic functions with signed or unsigned values
--use ieee.numeric_std.all;
 
entity SingleRegister_Testbench is
end SingleRegister_Testbench;
 
architecture behavior of SingleRegister_Testbench is 
 
    -- component declaration for the unit under test (uut)
 
   component SingleRegister
		generic (
			width : integer := 32
		);
		port ( 
			reset : in std_logic;
			clock : in std_logic;
			input : in  std_logic_vector (width - 1 downto 0);
			operation : in  std_logic;
			output : out  std_logic_vector (width - 1 downto 0)
		);
	end component;
    

   --inputs
   signal reset : std_logic := '0';
   signal clock : std_logic := '0';
   signal input : std_logic_vector(3 downto 0) := (others => '0');
   signal operation : std_logic := '0';

 	--outputs
   signal output : std_logic_vector(3 downto 0);

   -- clock period definitions
   constant clock_period : time := 20 ns;
 
begin
 
	-- instantiate the unit under test (uut)
	uut: SingleRegister generic map (width => 4)
	port map (
		reset => reset,
		clock => clock,
		input => input,
		operation => operation,
		output => output
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
		wait for clock_period*2;

		reset <= '1';
		operation <= '1';
		input <= "0101";
		wait for clock_period;
		
		reset <= '1';
		operation <= '0';
		input <= "1010";
		wait for clock_period;
	  
	  	reset <= '1';
		operation <= '1';
		input <= "1110";
		wait for clock_period;
		
		reset <= '1';
		operation <= '0';
		input <= "0001";
		wait for clock_period;
		wait;
   end process;
end;
