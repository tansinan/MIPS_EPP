library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.MIPSCPU.all;
use work.HardwareController.all;
use work.VirtualHardware.all;
use std.textio.all;

entity VirtualRAM_c is
	generic (
		virtualRAMFileName : string;
		virtualRAMTempFileName : string
	);
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
		file tmpRAMFile : text;
		variable readResult : std_logic_vector(PHYSICS_RAM_DATA_WIDTH - 1 downto 0);
		variable writeData : std_logic_vector(PHYSICS_RAM_DATA_WIDTH - 1 downto 0);
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
			report content;
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
		
		procedure fileEditLine(
			lineNumber : integer;
			data : inout std_logic_vector(PHYSICS_RAM_DATA_WIDTH - 1 downto 0)
		) is
			variable contentLine : line;
		begin
			file_open(tmpRAMFile, virtualRAMFileName, READ_MODE);
			file_open(file_pointer, virtualRAMTempFileName, WRITE_MODE);
			for i in 0 to 1024 - 1 loop
				readline (tmpRAMFile, contentLine);
				if i /= lineNumber then
					writeline(file_pointer, contentLine);
				else
					fileWriteData(data);
				end if;
			end loop;
			file_close(tmpRAMFile);
			file_close(file_pointer);
			file_open(file_pointer, virtualRAMFileName, WRITE_MODE);
			file_open(tmpRAMFile, virtualRAMTempFileName, READ_MODE);
			for i in 0 to 1024 - 1 loop
				readline (tmpRAMFile, contentLine);
				writeline(file_pointer, contentLine);
			end loop;
			file_close(tmpRAMFile);
			file_close(file_pointer);
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
				file_open(file_pointer, virtualRAMFileName, READ_MODE);
				lineToRead := to_integer(unsigned(addressBus));
				report "Reading:" & integer'image(lineToRead);
				if lineToRead < 1024 then
					fileSeek(lineToRead);
					fileReadData(readResult);
				else
					report "RAM out of range";
				end if;
				dataBus <= readResult;
				file_close(file_pointer);
			elsif writeEnabled = FUNC_ENABLED then
				lineToRead := to_integer(unsigned(addressBus));
				report "Wrtiting:" & integer'image(lineToRead);
				if lineToRead < 1024 then
					writeData := dataBus;
					fileEditLine(to_integer(unsigned(addressBus)), writeData);
				else
					report "RAM out of range";
				end if;
			else
				report "Warning : Virtual RAM detected Read/Write enabled at same time!";
			end if;
		end if;
	end process;
end architecture;
