library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use work.MIPSCPU.all;
use std.textio.all;
 
entity Processor_Testbench is
end Processor_Testbench;

architecture behavior of Processor_Testbench is 
	
	-- Declare our processor to test.
	component Processor is
		port (
			reset : in std_logic;
			clock : in std_logic;
			instruction : in std_logic_vector(MIPS_CPU_INSTRUCTION_WIDTH - 1 downto 0);
			phyRAMEnable : out std_logic;
			phyRAMWriteEnable : out std_logic;
			phyRAMReadEnable : out std_logic;
			phyAddressBus : out std_logic_vector(PHYSICS_RAM_ADDRESS_WIDTH - 1 downto 0);
			phyDataBus : inout std_logic_vector(PHYSICS_RAM_DATA_WIDTH - 1 downto 0);
			register_file_debug : out mips_register_file_port
		);
	end component;
	
	component VirtualRAM_c is
		port (
			clock : in std_logic;
			reset : in std_logic;
			enabled : in std_logic;
			readEnabled : in std_logic;
			writeEnabled : in std_logic;
			addressBus : in std_logic_vector(PHYSICS_RAM_ADDRESS_WIDTH - 1 downto 0);
			dataBus : inout std_logic_vector(PHYSICS_RAM_DATA_WIDTH - 1 downto 0)
		);
	end component;

	-- CPU Clock.
	signal reset : std_logic := '0';
	signal clock : std_logic := '0';
	
	-- RAM Clock, they need to be slightly faster than the CPU clock
	-- for in our board it's always done in one clock cycle.
	signal ramClock : std_logic := '0';
	
	-- Bus interface
	signal phyRAMEnable : std_logic;
	signal phyRAMWriteEnable : std_logic;
	signal phyRAMReadEnable : std_logic;
	signal phyAddressBus : std_logic_vector(PHYSICS_RAM_ADDRESS_WIDTH - 1 downto 0);
	signal phyDataBus : std_logic_vector(PHYSICS_RAM_DATA_WIDTH - 1 downto 0);
	
	signal instruction : std_logic_vector(MIPS_CPU_INSTRUCTION_WIDTH - 1 downto 0);

 	--outputs
   signal register_file_debug : mips_register_file_port;
   signal current_test_success : boolean;
   file file_pointer : text;

   -- clock period definitions
   constant CLOCK_PERIOD : time := 20 ns;
   constant CPU_CLOCK_PERIOD : time := 20 ns;
   constant RAM_CLOCK_PERIOD : time := 10 ns;
begin
	-- instantiate the unit under test (uut)
	uut: Processor port map (
		reset => reset,
		clock => clock,
		instruction => instruction,
		phyRAMEnable => phyRAMEnable,
		phyRAMWriteEnable => phyRAMWriteEnable,
		phyRAMReadEnable => phyRAMReadEnable,
		phyAddressBus => phyAddressBus,
		phyDataBus => phyDataBus,
		register_file_debug => register_file_debug
	);

	virtualRam_e : VirtualRam_c port map (
		reset => reset,
		clock => ramClock,
		enabled => phyRAMEnable,
		writeEnabled => phyRAMWriteEnable,
		readEnabled => phyRAMReadEnable,
		addressBus => phyAddressBus,
		dataBus => phyDataBus
	);
   -- clock process definitions
   cpuClockProcess : process
   begin
		clock <= '0';
		wait for CPU_CLOCK_PERIOD/2;
		clock <= '1';
		wait for CPU_CLOCK_PERIOD/2;
   end process;
   
	ramClockProcess : process
	begin
		ramClock <= '0';
		wait for RAM_CLOCK_PERIOD/2;
		ramClock <= '1';
		wait for RAM_CLOCK_PERIOD/2;
	end process;
 

   -- stimulus process
	stim_proc: process

		procedure systemReset is
		begin
			reset <= '0';
			wait for clock_period * 10;
		end procedure;
		
		procedure executeInstruction (
			code : std_logic_vector(32 - 1 downto 0)
		) is
		begin
			current_test_success <= true;
			reset <= '1';
			instruction <= code;
			wait for clock_period * 5;
		end procedure;
	begin
	
	
	
   	--file_open(file_pointer, "Z:\\a.txt", WRITE_MODE);
    --for i in 0 to 1023 loop
	--	bin_value := conv_std_logic_vector(i,32);
	--	fileWriteData(bin_value);
	--end loop;
	--file_close(file_pointer);

	--file_open(file_pointer, "Z:\\a.txt", READ_MODE);
	
	--m := 0;
	
	--fileSeek(m);
	--fileReadData(bin_value);
	
	--m := 13;
	--fileSeek(m);
	--fileReadData(bin_value);
	--file_close(file_pointer);
	
	systemReset;
		
executeInstruction("10001100000000010000000000000010");

if current_test_success = true then
  if register_file_debug(0) /= "00000000000000000000000000000000" then
    report "Test case 1 failed";
  current_test_success <= false;
  end if;
end if;

if current_test_success = true then
  if register_file_debug(1) /= "00000000000000000000000000000010" then
    report "Test case 1 failed";
  current_test_success <= false;
  end if;
end if;

if current_test_success = true then
  if register_file_debug(2) /= "00000000000000000000000000000000" then
    report "Test case 1 failed";
  current_test_success <= false;
  end if;
end if;

if current_test_success = true then
  if register_file_debug(3) /= "00000000000000000000000000000000" then
    report "Test case 1 failed";
  current_test_success <= false;
  end if;
end if;

if current_test_success = true then
  if register_file_debug(4) /= "00000000000000000000000000000000" then
    report "Test case 1 failed";
  current_test_success <= false;
  end if;
end if;

if current_test_success = true then
  if register_file_debug(5) /= "00000000000000000000000000000000" then
    report "Test case 1 failed";
  current_test_success <= false;
  end if;
end if;

if current_test_success = true then
  if register_file_debug(6) /= "00000000000000000000000000000000" then
    report "Test case 1 failed";
  current_test_success <= false;
  end if;
end if;

if current_test_success = true then
  if register_file_debug(7) /= "00000000000000000000000000000000" then
    report "Test case 1 failed";
  current_test_success <= false;
  end if;
end if;

if current_test_success = true then
  if register_file_debug(8) /= "00000000000000000000000000000000" then
    report "Test case 1 failed";
  current_test_success <= false;
  end if;
end if;

if current_test_success = true then
  if register_file_debug(9) /= "00000000000000000000000000000000" then
    report "Test case 1 failed";
  current_test_success <= false;
  end if;
end if;

if current_test_success = true then
  if register_file_debug(10) /= "00000000000000000000000000000000" then
    report "Test case 1 failed";
  current_test_success <= false;
  end if;
end if;

if current_test_success = true then
  if register_file_debug(11) /= "00000000000000000000000000000000" then
    report "Test case 1 failed";
  current_test_success <= false;
  end if;
end if;

if current_test_success = true then
  if register_file_debug(12) /= "00000000000000000000000000000000" then
    report "Test case 1 failed";
  current_test_success <= false;
  end if;
end if;

if current_test_success = true then
  if register_file_debug(13) /= "00000000000000000000000000000000" then
    report "Test case 1 failed";
  current_test_success <= false;
  end if;
end if;

if current_test_success = true then
  if register_file_debug(14) /= "00000000000000000000000000000000" then
    report "Test case 1 failed";
  current_test_success <= false;
  end if;
end if;

if current_test_success = true then
  if register_file_debug(15) /= "00000000000000000000000000000000" then
    report "Test case 1 failed";
  current_test_success <= false;
  end if;
end if;

if current_test_success = true then
  if register_file_debug(16) /= "00000000000000000000000000000000" then
    report "Test case 1 failed";
  current_test_success <= false;
  end if;
end if;

if current_test_success = true then
  if register_file_debug(17) /= "00000000000000000000000000000000" then
    report "Test case 1 failed";
  current_test_success <= false;
  end if;
end if;

if current_test_success = true then
  if register_file_debug(18) /= "00000000000000000000000000000000" then
    report "Test case 1 failed";
  current_test_success <= false;
  end if;
end if;

if current_test_success = true then
  if register_file_debug(19) /= "00000000000000000000000000000000" then
    report "Test case 1 failed";
  current_test_success <= false;
  end if;
end if;

if current_test_success = true then
  if register_file_debug(20) /= "00000000000000000000000000000000" then
    report "Test case 1 failed";
  current_test_success <= false;
  end if;
end if;

if current_test_success = true then
  if register_file_debug(21) /= "00000000000000000000000000000000" then
    report "Test case 1 failed";
  current_test_success <= false;
  end if;
end if;

if current_test_success = true then
  if register_file_debug(22) /= "00000000000000000000000000000000" then
    report "Test case 1 failed";
  current_test_success <= false;
  end if;
end if;

if current_test_success = true then
  if register_file_debug(23) /= "00000000000000000000000000000000" then
    report "Test case 1 failed";
  current_test_success <= false;
  end if;
end if;

if current_test_success = true then
  if register_file_debug(24) /= "00000000000000000000000000000000" then
    report "Test case 1 failed";
  current_test_success <= false;
  end if;
end if;

if current_test_success = true then
  if register_file_debug(25) /= "00000000000000000000000000000000" then
    report "Test case 1 failed";
  current_test_success <= false;
  end if;
end if;

if current_test_success = true then
  if register_file_debug(26) /= "00000000000000000000000000000000" then
    report "Test case 1 failed";
  current_test_success <= false;
  end if;
end if;

if current_test_success = true then
  if register_file_debug(27) /= "00000000000000000000000000000000" then
    report "Test case 1 failed";
  current_test_success <= false;
  end if;
end if;

if current_test_success = true then
  if register_file_debug(28) /= "00000000000000000000000000000000" then
    report "Test case 1 failed";
  current_test_success <= false;
  end if;
end if;

if current_test_success = true then
  if register_file_debug(29) /= "00000000000000000000000000000000" then
    report "Test case 1 failed";
  current_test_success <= false;
  end if;
end if;

if current_test_success = true then
  if register_file_debug(30) /= "00000000000000000000000000000000" then
    report "Test case 1 failed";
  current_test_success <= false;
  end if;
end if;

if current_test_success = true then
  if register_file_debug(31) /= "00000000000000000000000000000000" then
    report "Test case 1 failed";
  current_test_success <= false;
  end if;
end if;

if current_test_success = true then
  report "Test case 1 succeeded";
end if;	
		reset <= '1';
		instruction <= MIPS_CPU_INSTRUCTION_NOP;
		wait for clock_period * 5;
		
		wait;

   end process;
end;
