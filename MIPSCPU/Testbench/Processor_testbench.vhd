library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use work.MIPSCPU.all;
use work.MIPSCP0.all;
use work.HardwareController.all;
use work.VirtualHardware.all;

entity Processor_Testbench is
end Processor_Testbench;

architecture behavior of Processor_Testbench is

	-- CPU Clock.
	signal reset : std_logic := '0';
	signal clock50M : std_logic := '0';

	-- RAM Clock, they need to be slightly faster than the CPU clock
	-- for in our board it's always done in one clock cycle.
	signal ramClock : std_logic := '0';

	-- Primary SRAM ports
	signal primaryPhysicsRAMControl : PhysicsRAMControl_t;
	signal primaryPhysicsRAMAddressBus : PhysicsRAMAddress_t;
	signal primaryPhysicsRAMDataBus : PhysicsRAMData_t;
	
	-- Secondary SRAM ports
	signal secondaryPhysicsRAMControl : PhysicsRAMControl_t;
	signal secondaryPhysicsRAMAddressBus : PhysicsRAMAddress_t;
	signal secondaryPhysicsRAMDataBus : PhysicsRAMData_t;
	
	-- First UART ports
	signal uart1Transmit : std_logic;
	signal uart1Receive : std_logic;

 	--outputs
	signal debugData : CPUDebugData_t;
	signal current_test_success : boolean;

	-- clock period definitions
	constant CLOCK_PERIOD : time := 20 ns;
	constant CPU_CLOCK_PERIOD : time := 20 ns;
	constant RAM_CLOCK_PERIOD : time := 10 ns;
begin
	processorTop_i : entity work.ProcessorTop
	port map
	(
		clock50M => clock50M,
		reset => reset,
		primaryPhysicsRAMControl => primaryPhysicsRAMControl,
		primaryPhysicsRAMAddressBus => primaryPhysicsRAMAddressBus,
		primaryPhysicsRAMDataBus => primaryPhysicsRAMDataBus,
		secondaryPhysicsRAMControl => secondaryPhysicsRAMControl,
		secondaryPhysicsRAMAddressBus => secondaryPhysicsRAMAddressBus,
		secondaryPhysicsRAMDataBus => secondaryPhysicsRAMDataBus,
		uart1Transmit => uart1Transmit,
		uart1Receive => uart1Receive,
		debugData => debugData
	);
	
	virtualPrimaryRam_i :entity work.VirtualRam_c
	generic map(
		virtualRAMFileName => VIRTUAL_HARDWARE_PRIMARY_RAM_FILE,
		virtualRAMTempFileName => VIRTUAL_HARDWARE_PRIMARY_RAM_TEMP_FILE
	)
	port map (
		reset => reset,
		clock => ramClock,
		enabled => primaryPhysicsRAMControl.enabled,
		writeEnabled => primaryPhysicsRAMControl.writeEnabled,
		readEnabled => primaryPhysicsRAMControl.readEnabled,
		addressBus => primaryPhysicsRAMAddressBus,
		dataBus => primaryPhysicsRAMDataBus
	);
	
	virtualSecondaryRam_i : entity work.VirtualRam_c
	generic map(
		virtualRAMFileName => VIRTUAL_HARDWARE_SECONDARY_RAM_FILE,
		virtualRAMTempFileName => VIRTUAL_HARDWARE_SECONDARY_RAM_TEMP_FILE
	)
	port map (
		reset => reset,
		clock => ramClock,
		enabled => secondaryPhysicsRAMControl.enabled,
		writeEnabled => secondaryPhysicsRAMControl.writeEnabled,
		readEnabled => secondaryPhysicsRAMControl.readEnabled,
		addressBus => secondaryPhysicsRAMAddressBus,
		dataBus => secondaryPhysicsRAMDataBus
	);
	
	virtualUART1 : entity work.VirtualUART
	generic map
	(
		baudRate => 115200
	)
    port map
	(
		uartReceive => uart1Transmit,
		uartTransmit => uart1Receive
	);

	-- CPU clock
	cpuClockProcess : process
	begin
		clock50M <= '0';
		wait for CPU_CLOCK_PERIOD/2;
		clock50M <= '1';
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
