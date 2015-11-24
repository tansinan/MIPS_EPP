library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.MIPSCPU.all;
use std.textio.all;

entity VirtualRAM_c is
	port (
		clock : in std_logic;
		reset : in std_logic;
		enabled : in std_logic;
		readEnabled : in std_logic;
		writeEnabled : in std_logic;
		addressBus : in std_logic_vector(PHYSICS_RAM_ADDRESS_WIDTH - 1 downto 0);
		dataBus : inout std_logic_vector(PHYSICS_RAM_DATA_WIDTH - 1 downto 0)
	);
end entity;

architecture behavior of VirtualRAM_c is
begin
	process(clock, reset)
		file file_pointer : text;
		variable readResult : std_logic_vector(32 - 1 downto 0);
		variable lineToRead : integer;
		procedure fileWriteData(
			variable data : std_logic_vector(PHYSICS_RAM_DATA_WIDTH - 1 downto 0)		
		) is
			variable content : string(1 to PHYSICS_RAM_DATA_WIDTH);
			variable contentLine : line;
		begin
			for i in 0 to PHYSICS_RAM_DATA_WIDTH - 1 loop
				if data(i) = '0' then
					content(PHYSICS_RAM_DATA_WIDTH - i) := '0';
				else
					content(PHYSICS_RAM_DATA_WIDTH - i) := '1';
				end if; 
			end loop;
			write(contentLine, content);
			writeline(file_pointer, contentLine);
		end procedure;
		
		procedure fileReadData(
			variable data : inout std_logic_vector(PHYSICS_RAM_DATA_WIDTH - 1 downto 0)		
		) is
			variable content : string(1 to PHYSICS_RAM_DATA_WIDTH);
			variable contentLine : line;
			variable char : character := '0'; 
		begin
			readline(file_pointer, contentLine);
			read(contentLine,content);
			report content;
			for i in 1 to PHYSICS_RAM_DATA_WIDTH loop        
				char := content(i);
				if char = '0' then
					data(PHYSICS_RAM_DATA_WIDTH - i) := '0';
				else
					data(PHYSICS_RAM_DATA_WIDTH - i) := '1';
				end if; 
			end loop;
		end procedure;
		
		procedure fileSeek(
			lineNumber : integer
		) is
			variable contentLine : line;
		begin
			if lineNumber /= 0 then
				for i in 0 to lineNumber - 1 loop
					readline (file_pointer, contentLine);
				end loop;
			end if;
		end procedure;
	begin
		if reset = '0' then
			dataBus <= (others => 'Z');
		elsif rising_edge(clock) then
			if enabled = FUNC_DISABLED then
				dataBus <= (others => 'Z');
			elsif readEnabled = FUNC_DISABLED and writeEnabled = FUNC_DISABLED then
				dataBus <= (others => 'Z');
			elsif readEnabled = FUNC_ENABLED then
				file_open(file_pointer, "Z:\\a.txt", READ_MODE);
				lineToRead := to_integer(unsigned(addressBus));
				fileSeek(lineToRead);
				fileReadData(readResult);
				dataBus <= readResult;
				file_close(file_pointer);
			elsif writeEnabled = FUNC_ENABLED then
				report "Virtual RAM Read is not implemented.";
			else
				report "Warning : Virtual RAM detected Read/Write enabled at same time!";
			end if;
		end if;
	end process;
end architecture;
