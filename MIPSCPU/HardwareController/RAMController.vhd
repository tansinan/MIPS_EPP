library ieee;
use ieee.std_logic_1164.all;
use work.MIPSCPU.all;
use work.HardwareController.all;

entity RAMController_e is
	port (
		clock : in Clock_t;
		reset : in Reset_t;
		control : in HardwareRAMControl_t;
		result : out PhysicsRAMData_t;
		physicsRAMControl : out PhysicsRAMControl_t;
		physicsAddressBus : out PhysicsRAMAddress_t;
		physicsDataBus : inout PhysicsRAMData_t
	);
	type RAMControllerState is
	(
		RAM_CONTROLLER_STATE_ACTIVE,
		RAM_CONTROLLER_STATE_IDLE
	);
end entity;

architecture Behavioral of RAMController_e is
	signal state : RAMControllerState;
	signal lastControl : HardwareRAMControl_t;
begin
	physicsRAMControl.enabled <= FUNC_ENABLED;
	process(clock, reset)
	begin
		if reset = '0' then
			physicsRAMControl.writeEnabled <= FUNC_DISABLED;
			physicsRAMControl.readEnabled <= FUNC_DISABLED;
			physicsAddressBus <= (others => '0');
			physicsDataBus <= (others => 'Z');
			state <= RAM_CONTROLLER_STATE_IDLE;
		elsif rising_edge(clock) then
			if state = RAM_CONTROLLER_STATE_IDLE then
				lastControl <= control;
				if lastControl /= control then
					if control.readEnabled = FUNC_ENABLED and 
					control.writeEnabled = FUNC_ENABLED then
						report "Warning: attempting to perform read and write on SRAM and the same time"
						severity failure;
						physicsRAMControl.writeEnabled <= FUNC_DISABLED;
						physicsRAMControl.readEnabled <= FUNC_DISABLED;
						physicsAddressBus <= (others => '0');
						physicsDataBus <= (others => 'Z');
					else
						physicsRAMControl.writeEnabled <= control.writeEnabled;
						physicsRAMControl.readEnabled <= control.readEnabled;
						physicsAddressBus <= control.address;
						if control.readEnabled = FUNC_ENABLED then
							physicsDataBus <= (others => 'Z');
						elsif control.writeEnabled = FUNC_ENABLED then
							physicsDataBus <= control.data;
						else
							physicsDataBus <= (others => 'Z');
						end if;
						state <= RAM_CONTROLLER_STATE_ACTIVE;
					end if;
				end if;
			elsif state = RAM_CONTROLLER_STATE_ACTIVE then
				result <= physicsDataBus;
				physicsRAMControl.writeEnabled <= FUNC_DISABLED;
				physicsRAMControl.readEnabled <= FUNC_DISABLED;
				physicsAddressBus <= (others => '0');
				physicsDataBus <= (others => 'Z');
				state <= RAM_CONTROLLER_STATE_IDLE;
			end if;
		end if;
	end process;
end architecture;
