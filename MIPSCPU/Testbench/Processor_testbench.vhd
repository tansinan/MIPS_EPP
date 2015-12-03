library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use work.MIPSCPU.all;

entity Processor_Testbench is
end Processor_Testbench;

architecture behavior of Processor_Testbench is

	-- Declare our processor to test.
	component Processor is
		port (
			reset : in std_logic;
			clock : in std_logic;
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

 	--outputs
	signal register_file_debug : mips_register_file_port;
	signal current_test_success : boolean;

	-- clock period definitions
	constant CLOCK_PERIOD : time := 20 ns;
	constant CPU_CLOCK_PERIOD : time := 20 ns;
	constant RAM_CLOCK_PERIOD : time := 10 ns;
begin
	-- instantiate the unit under test (uut)
	uut: Processor port map (
		reset => reset,
		clock => clock,
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

	-- CPU clock
	cpuClockProcess : process
	begin
		clock <= '0';
		wait for CPU_CLOCK_PERIOD/2;
		clock <= '1';
		wait for CPU_CLOCK_PERIOD/2;
	end process;

	-- RAM clock.
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
			reset <= FUNC_ENABLED;
			wait for clock_period * 10;
		end procedure;
	begin
		systemReset;
		reset <= FUNC_DISABLED;
		wait;
   end process;
end;
