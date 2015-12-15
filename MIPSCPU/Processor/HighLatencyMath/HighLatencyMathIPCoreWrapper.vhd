library ieee;
use ieee.std_logic_1164.all;
use work.MIPSCPU.all;

entity HighLatencyMathIPCoreWrapper is
	port
	(
		reset : in Reset_t;
		clock : in Clock_t;
		clock50M : in Clock_t;
		number1 : in CPUData_t;
		number1Signed : in EnablingControl_t;
		number2 : in CPUData_t;
		number2Signed : in EnablingControl_t;
		resultReady : out ReadyStatus_t;
		output : out CPUDoubleWordData_t
	);
end entity;

architecture Behavioral of HighLatencyMathIPCoreWrapper is
	signal mulIpCoreNumber1 : std_logic_vector(MIPS_CPU_DATA_WIDTH downto 0);
	signal mulIpCoreNumber2 : std_logic_vector(MIPS_CPU_DATA_WIDTH downto 0);
	signal mulIpCoreResult : std_logic_vector(MIPS_CPU_DATA_WIDTH * 2 + 2 downto 0);
	component ipcoremultiplier
	port (
		clk : in std_logic;
		a : in std_logic_vector(32 downto 0);
		b : in std_logic_vector(32 downto 0);
		p : out std_logic_vector(66 downto 0)
	);
end component;
begin

	ipCoreMultiplier_i : IPCoreMultiplier
	port map (
		clk => clock50M,
		a => mulIpCoreNumber1,
		b => mulIpCoreNumber2,
		p => mulIpCoreResult
	);
	process(clock, reset)
	begin
		if reset = FUNC_ENABLED then
			output <= (others => '0');
		elsif rising_edge(clock) then
			if number1Signed = FUNC_ENABLED then
				mulIpCoreNumber1 <= number1(MIPS_CPU_DATA_WIDTH - 1) & number1;
			else
				mulIpCoreNumber1 <= "0" & number1;
			end if;
			
			if number2Signed = FUNC_ENABLED then
				mulIpCoreNumber2 <= number2(MIPS_CPU_DATA_WIDTH - 1) & number2;
			else
				mulIpCoreNumber2 <= "0" & number2;
			end if;
			output(MIPS_CPU_DATA_WIDTH * 2 - 1 downto 0) <=
				mulIpCoreResult(MIPS_CPU_DATA_WIDTH * 2 - 1 downto 0);
		end if;
	end process;
end architecture;
