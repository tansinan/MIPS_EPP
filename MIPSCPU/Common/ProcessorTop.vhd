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
		uart1Receive : in std_logic;
		debugData : out CPUDebugData_t
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
		debugData => debugData,
		primaryRAMControl => primaryRAMControl,
		primaryRAMResult => primaryRAMResult,
		secondaryRAMControl => secondaryRAMControl,
		secondaryRAMResult => secondaryRAMResult,
		uart1control => uart1Control,
		uart1result => uart1Output
	);
	
	uartController : entity work.UARTController
	port map
	(
		reset => reset,
		clock => clockDivided,
		clock50M => clock50M,
		control => uart1Control,
		output => uart1Output,
		uartTransmit => uart1Transmit,
		uartReceive => uart1Receive
	);
end architecture;

