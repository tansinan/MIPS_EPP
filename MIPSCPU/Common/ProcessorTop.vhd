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
		primaryPhysicsRAMControl : out PhysicsRAMControl_t;
		primaryPhysicsRAMAddressBus : out PhysicsRAMAddress_t;
		primaryPhysicsRAMDataBus : inout PhysicsRAMData_t;
		secondaryPhysicsRAMControl : out PhysicsRAMControl_t;
		secondaryPhysicsRAMAddressBus : out PhysicsRAMAddress_t;
		secondaryPhysicsRAMDataBus : inout PhysicsRAMData_t;
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
	signal uartControl : HardwareRegisterControl_t;
	signal uartOutput : CPUData_t;
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
		register_file_debug => open,
		pcValueDebug => open,
		debugCP0RegisterFileData => open,
		debugInstructionToPrimary => open,
		primaryRAMControl => primaryRAMControl,
		primaryRAMResult => primaryRAMResult,
		secondaryRAMControl => secondaryRAMControl,
		secondaryRAMResult => secondaryRAMResult
	);
	
	uartController : entity work.UARTController
	port map
	(
		reset => reset,
		clock => clockDivided,
		clock50M => clock50M,
		control => uartControl,
		output => uartOutput,
		uartTransmit => uart1Transmit,
		uartReceive => uart1Receive
	);
end architecture;

