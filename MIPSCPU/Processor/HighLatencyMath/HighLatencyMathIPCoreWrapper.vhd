library ieee;
use ieee.std_logic_1164.all;
use work.MIPSCPU.all;

entity HighLatencyMathIPCoreWrapper is
	port
	(
		reset : in Reset_t;
		clock : in Clock_t;
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
begin
	ipCoreMultiplier_i :entity work.IPCoreMultiplier
	port map (
		clk => clock,
		a => mulIpCoreNumber1,
		b => mulIpCoreNumber2,
		p => mulIpCoreResult
	);
	process(clock, reset)
	begin
		if reset = FUNC_ENABLED then
			output <= (others => '0');
		elsif rising_edge(clock) then
			mulIpCoreNumber1 <= "0" & number1;
			mulIpCoreNumber2 <= "0" & number2;
			output(31 downto 0) <= mulIpCoreResult(31 downto 0);
		end if;
	end process;
end architecture;
