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
		control : in HardwareRegisterControl_t;
		output : out CPUData_t;
		interruptTrigger : out CP0HardwareInterruptTrigger_t;
		uartTransmit : out std_logic;
		uartReceive : in std_logic
	);
end entity;

architecture Behavioral of UARTController is
	signal canRead : CPUData_t;
	signal canWrite : CPUData_t;
	signal dataWrite : std_logic_vector(7 downto 0);
	signal dataRead : std_logic_vector(7 downto 0);
	signal writeSTB : std_logic;
	signal writeACK : std_logic;
	signal readSTB : std_logic;
	signal readACK : std_logic;
	signal isWriting : std_logic;
	signal readBuffer : std_logic_vector(7 downto 0);
	signal readBufferAvailable : std_logic;
	signal finishReading : std_logic;
	signal uartModuleReset : std_logic;
begin
	-- The UART module use '1' as reset enable instead of '0'
	uartModuleReset <= not reset;
	UART_i : entity work.UART
	generic map (
			baud => 115200,
			clock_frequency => 24998400
		)
	port map (
		clock => clock,
		reset => uartModuleReset,
		data_stream_in => dataWrite,
		data_stream_in_stb => writeSTB,
		data_stream_in_ack => writeACK,
		data_stream_out => dataRead,
		data_stream_out_stb => readSTB,
		tx => uartTransmit,
		rx => uartReceive
	);
	
	-- TODO : Add Interrupt trigger to UART Controller module!
	interruptTrigger <= (
		enabled => FUNC_DISABLED,
		interruptCodeMask => (others => '0')
	);
	
	process(reset, clock, control)
		variable hardwareRegisterAddress : std_logic_vector(11 downto 0);
	begin
		hardwareRegisterAddress := control.address(11 downto 0);
		if reset = FUNC_ENABLED then
			output <= (others => '0');
			isWriting <= '0';
			finishReading <= '0';
			writeSTB <= '0';
			readBuffer <= (others => '0');
			readBufferAvailable <= '0';
		elsif rising_edge(clock) then
			-- Handles the signals of the UART module
			if isWriting = '1' then
				if writeSTB = '0' then
					writeSTB <= '1';
				elsif writeACK = '1' then
					writeSTB <= '0';
					isWriting <= '0';
				end if;
			end if;
			if readSTB = '1' then
				readBuffer <= dataRead;
				readBufferAvailable <= '1';
			end if;
			if hardwareRegisterAddress = UART1_REGISTER_DATA then
				if control.operation = REGISTER_OPERATION_WRITE then
					if isWriting = '0' then
						--dataWrite <= "01000001";
						dataWrite <= control.data(7 downto 0);
						isWriting <= '1';
						--writeSTB <= '1';
					end if;
				elsif control.operation = REGISTER_OPERATION_READ then
					if readBufferAvailable = '1' then
						output(MIPS_CPU_DATA_WIDTH - 1 downto 8) <= (others => '0');
						output(7 downto 0) <= readBuffer;
						--output(7 downto 0) <= x"31";
						readBufferAvailable <= '0';
					else
						output <= (others => '0');
					end if;
				end if;
			elsif hardwareRegisterAddress = UART1_REGISTER_STATUS then
				if control.operation = REGISTER_OPERATION_READ then
					output(MIPS_CPU_DATA_WIDTH - 1 downto 0) <= (others => '0');
					if readBufferAvailable = '1' then
						output(UART1_REGISTER_STATUS_BIT_CAN_READ) <= '1';
					end if;
					if writeSTB = '0' and writeACK = '0' then
						output(UART1_REGISTER_STATUS_BIT_CAN_WRITE) <= '1';
					end if;
				end if;
			end if;
		end if;
	end process;
end architecture;

