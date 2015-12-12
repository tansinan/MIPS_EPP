library ieee;
use ieee.std_logic_1164.all;
use work.MIPSCPU.all;
use work.MIPSCP0.all;
use work.HardwareController.all;
use std.textio.all;

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
	signal inputBufferNotEmpty : boolean;
	signal inputBufferCharacter : integer;
begin
	-- This virtual UART module from 
	process
		subtype UnsignedChar_t is std_logic_vector(7 downto 0);
		type BinaryFile_t is file of Character;
		variable hardwareRegisterAddress : std_logic_vector(11 downto 0);
		variable ch : Character;
		file outputFile : BinaryFile_t;
	begin
		file_open(outputFile, "/tmp/uartsimutest", WRITE_MODE);
		for i in 65 to 77 loop
		ch := character'val(i);
		write(outputFile, ch);
		end loop;
		file_close(outputFile);
		wait;
	end process;
	process(reset, clock)
		type BinaryFile_t is file of integer;
		variable hardwareRegisterAddress : std_logic_vector(11 downto 0);
		file output : BinaryFile_t;
	begin
		hardwareRegisterAddress := control.address(11 downto 0);
		if reset = FUNC_ENABLED then
		elsif rising_edge(clock) then
			if hardwareRegisterAddress = UART1_REGISTER_DATA then
				if control.operation = REGISTER_OPERATION_READ then
				elsif control.operation = REGISTER_OPERATION_WRITE then
				end if;
			elsif hardwareRegisterAddress = UART1_REGISTER_STATUS then
				if control.operation = REGISTER_OPERATION_READ then
				end if;
			end if;
		end if;
	end process;
end architecture;

