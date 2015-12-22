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
		isDivision : in EnablingControl_t;
		isMultiplication : in EnablingControl_t;
		resultReady : out ReadyStatus_t;
		output : out CPUDoubleWordData_t
	);
	type IPCoreWrapperState_t is (
		STATE_MUL,
		STATE_DIV,
		STATE_IDLE
	);
end entity;

architecture Behavioral of HighLatencyMathIPCoreWrapper is
	signal mulIpCoreNumber1 : std_logic_vector(MIPS_CPU_DATA_WIDTH downto 0);
	signal mulIpCoreNumber2 : std_logic_vector(MIPS_CPU_DATA_WIDTH downto 0);
	signal mulIpCoreResult : std_logic_vector(MIPS_CPU_DATA_WIDTH * 2 + 2 downto 0);
	signal divIpCoreNumber1 : std_logic_vector(39 downto 0);
	signal divIpCoreNumber2 : std_logic_vector(39 downto 0);
	signal divIpCoreResult : std_logic_vector(79 downto 0);
	signal divIpCoreEnabled : std_logic;
	signal state : IPCoreWrapperState_t;
	signal cyclesRemain : integer range 0 to 127;
	component IPCoreMultiplier
	port (
		clk : in std_logic;
		a : in std_logic_vector(32 downto 0);
		b : in std_logic_vector(32 downto 0);
		p : out std_logic_vector(66 downto 0)
	);
	end component;
	component IPCoreDivider
	port (
		aclk : in std_logic;
		s_axis_divisor_tvalid : in std_logic;
		s_axis_divisor_tready : out std_logic;
		s_axis_divisor_tdata : in std_logic_vector(39 downto 0);
		s_axis_dividend_tvalid : in std_logic;
		s_axis_dividend_tready : out std_logic;
		s_axis_dividend_tdata : in std_logic_vector(39 downto 0);
		m_axis_dout_tvalid : out std_logic;
		m_axis_dout_tdata : out std_logic_vector(79 downto 0)
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
	
	ipCoreDivider_i : IPCoreDivider
	port map (
		aclk => clock50M,
		s_axis_divisor_tvalid => divIpCoreEnabled,
		s_axis_divisor_tready => open,
		s_axis_divisor_tdata => divIpCoreNumber2,
		s_axis_dividend_tvalid => divIpCoreEnabled,
		s_axis_dividend_tready => open,
		s_axis_dividend_tdata => divIpCoreNumber1,
		m_axis_dout_tvalid => open,
		m_axis_dout_tdata => divIpCoreResult
	);
	
	process(clock, reset)
	begin
		if reset = FUNC_ENABLED then
			output <= (others => '0');
			state <= STATE_IDLE;
		elsif rising_edge(clock) then
			if state = STATE_IDLE then
				if isMultiplication = FUNC_ENABLED then
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
					divIpCoreEnabled <= '0';
					cyclesRemain <= 5;
					state <= STATE_MUL;
				elsif isDivision = FUNC_ENABLED then
					if number1Signed = FUNC_ENABLED then
						if number1(MIPS_CPU_DATA_WIDTH - 1) = '0' then
							divIpCoreNumber1 <= "00000000" & number1;
						else
							divIpCoreNumber1 <= "11111111" & number1;
						end if;
					else
						divIpCoreNumber1 <= "00000000" & number1;
					end if;
					
					if number2Signed = FUNC_ENABLED then
						if number2(MIPS_CPU_DATA_WIDTH - 1) = '0' then
							divIpCoreNumber2 <= "00000000" & number2;
						else
							divIpCoreNumber2 <= "11111111" & number2;
						end if;
					else
						divIpCoreNumber2 <= "00000000" & number2;
					end if;
					divIpCoreEnabled <= '1';
					cyclesRemain <= 25;
					state <= STATE_DIV;
				end if;
			elsif state = STATE_MUL then
				cyclesRemain <= cyclesRemain - 1;
				if cyclesRemain = 0 then
					output(MIPS_CPU_DATA_WIDTH * 2 - 1 downto 0) <=
						mulIpCoreResult(MIPS_CPU_DATA_WIDTH * 2 - 1 downto 0);
					state <= STATE_IDLE;
				end if;
			elsif state = STATE_DIV then
				cyclesRemain <= cyclesRemain - 1;
				if cyclesRemain = 0 then
					output(MIPS_CPU_DATA_WIDTH - 1 downto 0) <= divIpCoreResult(MIPS_CPU_DATA_WIDTH - 1 + 40 downto 40);
					output(MIPS_CPU_DATA_WIDTH * 2 - 1 downto MIPS_CPU_DATA_WIDTH) <=
						divIpCoreResult(MIPS_CPU_DATA_WIDTH - 1 downto 0);
					state <= STATE_IDLE;
				end if;
			end if;
		end if;
	end process;
	with state select resultReady <=
		STATUS_READY when STATE_IDLE,
		STATUS_BUSY when others;
end architecture;
