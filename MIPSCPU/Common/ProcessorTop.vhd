library ieee;
use ieee.std_logic_1164.all;
use work.MIPSCPU.all;
use work.MIPSCP0.all;
use work.HardwareController.all;

entity ProcessorTop is
	port
	(
		clock50M : in Clock_t;
		reset : in Reset_t;
		
		-- Primary physics RAM hardware interface.
		primaryPhysicsRAMControl : out PhysicsRAMControl_t;
		primaryPhysicsRAMAddressBus : out PhysicsRAMAddress_t;
		primaryPhysicsRAMDataBus : inout PhysicsRAMData_t;
		
		-- Secondary physics RAM hardware interface.
		secondaryPhysicsRAMControl : out PhysicsRAMControl_t;
		secondaryPhysicsRAMAddressBus : out PhysicsRAMAddress_t;
		secondaryPhysicsRAMDataBus : inout PhysicsRAMData_t;
		
		-- FlashROM hardware interface.
		flashByte : out std_logic;
		flashVPEN : out std_logic;
		flashCE : out std_logic;
		flashCE1 : out std_logic;
		flashCE2 : out std_logic;
		flashOE : out std_logic;
		flashWE : out std_logic;
		flashRP : out std_logic;
		flashAddress : out std_logic_vector(22 downto 0);
		flashData : inout std_logic_vector(15 downto 0);
		
		-- LED for debugging.
		light : out std_logic_vector(15 downto 0);
		
		-- UART hardware interface
		uart1Transmit : out std_logic;
		uart1Receive : in std_logic
	);
end entity;

architecture Behavioral of ProcessorTop is
	signal clockDivided : Clock_t;
	signal primaryRAMControl : HardwareRAMControl_t;
	signal secondaryRAMControl : HardwareRAMControl_t;
	signal primaryRAMResult : RAMData_t;
	signal secondaryRAMResult : RAMData_t;
	signal uart1Control : HardwareRegisterControl_t;
	signal uart1Output : CPUData_t;
	signal flashROMControl : HardwareRegisterControl_t;
	signal flashROMOutput : CPUData_t;
	signal debugData : CPUDebugData_t;
	signal cp0ExternalInterruptSource : CP0ExternalInterruptSource_t;
begin
	primaryRAMController_i : entity work.RAMController_e
	port map (
		clock => clock50M,
		reset => reset,
		control => primaryRAMControl,
		result => primaryRAMResult,
		physicsRAMControl => primaryPhysicsRAMControl,
		physicsAddressBus => primaryPhysicsRAMAddressBus,
		physicsDataBus => primaryPhysicsRAMDataBus
	);

	secondaryRAMController_i : entity work.RAMController_e
	port map (
		clock => clock50M,
		reset => reset,
		control => secondaryRAMControl,
		result => secondaryRAMResult,
		physicsRAMControl => secondaryPhysicsRAMControl,
		physicsAddressBus => secondaryPhysicsRAMAddressBus,
		physicsDataBus => secondaryPhysicsRAMDataBus
	);

	clockDivider_i : entity work.ClockDivider_e
	port map (
		clockIn => clock50M,
		reset => reset,
		clockOut => clockDivided
	);
	
	processor_i : entity work.Processor
	port map (
		reset => reset,
		clock => clockDivided,
		clock50M => clock50M,
		debugData => debugData,
		primaryRAMControl => primaryRAMControl,
		primaryRAMResult => primaryRAMResult,
		secondaryRAMControl => secondaryRAMControl,
		secondaryRAMResult => secondaryRAMResult,
		uart1control => uart1Control,
		uart1result => uart1Output,
		cp0ExternalInterruptSource => cp0ExternalInterruptSource,
		light => light
	);
	
	uartController : entity work.UARTController
	port map
	(
		reset => reset,
		clock => clockDivided,
		control => uart1Control,
		output => uart1Output,
		uartTransmit => uart1Transmit,
		uartReceive => uart1Receive,
		interruptTrigger => cp0ExternalInterruptSource(0)
	);
	
	flashRomController_i : entity work.FlashRomController
	port map
	(
		-- TODO : need to consider which clock to use.
		clock => clockDivided,
		reset => reset,
		control => flashROMControl,
		output => flashROMOutput,
		flashByte => flashByte,
		flashVPEN => flashVPEN,
		flashCE => flashCE,
		flashCE1 => flashCE1,
		flashCE2 => flashCE2,
		flashOE => flashOE,
		flashWE => flashWE,
		flashRP => flashRP,
		flashAddress => flashAddress,
		flashData => flashData
	);
end architecture;

