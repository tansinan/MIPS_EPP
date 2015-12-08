library ieee;
use ieee.std_logic_1164.all;
use work.MIPSCPU.all;
use work.MIPSCP0.all;
use work.HardwareController.all;

entity UARTController is
	port
	(
		reset : in Reset_t;
		clock : in Clock_t;
		clock50M : in Clock_t;
		control : in HardwareRegisterControl_t;
		output : out CPUData_t;
		uartTransmit : out std_logic;
		uartReceive : in std_logic
	);
end entity;

architecture Behavioral of UARTController is
	signal canRead : CPUData_t;
	signal canWrite : CPUData_t;
	signal dataWrite : CPUData_t;
	signal dataRead : CPUData_t;
	signal writeSTB : std_logic;
	signal writeACK : std_logic;
	signal readSTB : std_logic;
	signal readACK : std_logic;
begin
	UART_i : entity work.UART
	generic map (
			BAUD_RATE => 115200,
			CLOCK_FREQUENCY => 50000000
		)
	port map (
		clock => clock50M,
		reset => not reset,
		DATA_STREAM_IN => dataWrite,
		DATA_STREAM_IN_STB => writeSTB,
		DATA_STREAM_IN_ACK => writeACK,
		DATA_STREAM_OUT => dataRead,
		DATA_STREAM_OUT_STB => readSTB,
		DATA_STREAM_OUT_ACK => readACK,
		TX => uartTransmit,
		RX => uartReceive
	);
	process(reset, clock)
		variable hardwareRegisterAddress : std_logic_vector(11 downto 0);
	begin
		hardwareRegisterAddress := control.address(11 downto 0);
		if reset = FUNC_ENABLED then
			output <= (others => '0');
		elsif rising_edge(clock) then
			if hardwareRegisterAddress = UART1_REGISTER_DATA then
				if control.operation = REGISTER_OPERATION_READ then
					if writeSTB = '0' and writeACK = '0' then
						dataWrite <= control.data(7 downto 0);
						writeSTB <= '1';
					end if;
				else
					output(MIPS_CPU_DATA_WIDTH - 1 downto 8) <= (others => '0');
					output(7 downto 0) <= dataRead;
				end if;
			end if;
		end if;
	end process;
end architecture;

