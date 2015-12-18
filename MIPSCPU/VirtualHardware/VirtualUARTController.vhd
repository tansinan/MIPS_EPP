library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.MIPSCPU.all;
use work.MIPSCP0.all;
use work.HardwareController.all;
use work.VirtualHardware.all;
use std.textio.all;

entity UARTController is
	port
	(
		reset : in Reset_t;
		clock : in Clock_t;
		clock11M : in Clock_t;
		control : in HardwareRegisterControl_t;
		output : out CPUData_t;
		uartTransmit : out std_logic;
		uartReceive : in std_logic
	);
end entity;

architecture behaviour of UARTController is
	signal inputBufferNotEmpty : boolean;
	signal inputBufferCharacter : integer;
begin
	process(reset, clock)
		type BinaryFile_t is file of Character;
		variable hardwareRegisterAddress : std_logic_vector(11 downto 0);
		variable ch : Character;
		file outputFile : BinaryFile_t;
	begin
		hardwareRegisterAddress := control.address(11 downto 0);
		if reset = FUNC_ENABLED then
		elsif rising_edge(clock) then
			if hardwareRegisterAddress = UART1_REGISTER_DATA then
				if control.operation = REGISTER_OPERATION_READ then
				elsif control.operation = REGISTER_OPERATION_WRITE then
					file_open(outputFile, VIRTUAL_HARDWARE_UART_OUTPUT_PIPE, WRITE_MODE);
					ch := character'val(to_integer(unsigned(control.data(7 downto 0))));
					write(outputFile, ch);
					file_close(outputFile);
				end if;
			elsif hardwareRegisterAddress = UART1_REGISTER_STATUS then
				if control.operation = REGISTER_OPERATION_READ then
					output <= (others => '1');
				end if;
			end if;
		end if;
	end process;
end architecture;

