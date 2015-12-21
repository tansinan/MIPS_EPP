library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.MIPSCPU.all;
use work.HardwareController.all;

-- IMPROTANT: Need to get clear with Flash Address!

entity BootLoader is
    port
    (
        reset : in Reset_t;
        clock : in Clock_t;
				
        -- Connect with flash ROM
        flashByte : out std_logic;
        flashVPEN : out std_logic;
        flashCE, flashOE, flashWE : out std_logic;
        flashRP : out std_logic;
        flashAddress : out std_logic_vector(22 downto 0);
        flashData : inout std_logic_vector(15 downto 0);
				
				-- Connect with RAM
				physicsRAMControl : out PhysicsRAMControl_t;
				physicsAddressBus : out PhysicsRAMAddress_t;
				physicsDataBus : inout PhysicsRAMData_t;
				
				--Connect with other CPU Parts
				bootAddressSize : in std_logic_vector(13 downto 0);
				workFinished : std_logic
    );
	type bootLoaderState is
	(
		READ_FLASH_1_COMMAND,
		READ_FLASH_2_COMMAND,
		READ_FLASH_1_WAIT,
		READ_FLASH_2_WAIT,
		WORK_FINISHED
	);
end entity;

architecture Behavioral of BootLoader is
    -- Connect with FlashRomModule
	signal flashWriteEnable : std_logic;
	signal flashReadEnable : std_logic;
	signal flashDataDisplay : std_logic_vector(15 downto 0);
	signal flashDataControl : std_logic_vector(15 downto 0);
	signal flashAddressControl : std_logic_vector(22 downto 0);
	signal flashReadyStatus : ReadyStatus_t;
	-- Connect with RAMModule
	signal RAMControl : HardwareRAMControl_t;
	signal RAMResult : PhysicsRAMData_t;
	-- Not for connection
	signal state : bootLoaderState := READY_TO_GO;
	signal addressPtr : std_logic_vector(13 downto 0) := "00000000000000";
	signal RAMBuffer : std_logic_vector(15 downto 0);
begin
	flashROMModule_i : entity work.FlashRom
	port map (
		clock => clock,
		writeEnable => flashWriteEnable,
		readEnable => flashReadEnable,
		dataDisplay => flashDataDisplay,
		dataControl => flashDataControl,
		address => flashAddressControl,
		readyStatus => flashReadyStatus,
		
		flashByte => flashByte,
		flashVPEN => flashVPEN,
		flashCE => flashCE,
		flashOE => flashOE,
		flashWE => flashWE,
		flashRP => flashRP,
		flashAddress => flashAddress,
		flashData => flashData,
		reset => reset
	);
	ramController_i : entity work.RAMController_e
	port map (
		clock => clock,
		reset => reset,
		control => RAMControl,
		physicsRAMControl => PhysicsRAMControl,
		physicsAddressBus => PhysicsRAMAddress,
		physicsDataBus => PhysicsRAMData,
		result => RAMResult
	);
	
	process(clock, reset)
	begin
		if reset = '0' then
			state <= READ_FLASH_1_COMMAND;
			addressPtr <= (others => '0');
			workFinished <= '0';
			flashWriteEnable <= '1';
			flashReadEnable <= '1';
		elsif rising_edge(clock) then
			case state is
				when READ_FLASH_1_COMMAND =>
					if addressPtr > bootAddressSize then
						state <= WORK_FINISHED;
					elsif flashReadyStatus = STATUS_READY then
						flashWriteEnable <= '1';
						flashReadEnable <= '0';
						flashAddressControl(13 downto 0) <= addressPtr;
						state <= READ_FLASH_1_WAIT;
					end if;
				
				when READ_FLASH_1_WAIT =>
					flashWriteEnable <= '1';
					flashReadEnable <= '1';
					if flashReadyStatus = STATUS_READY then
						RAMBuffer <= flashDataDisplay;
						state <= READ_FLASH_2_COMMAND;
						addressPtr <= addressPtr + '1';
					end if;
				
				when READ_FLASH_2_COMMAND =>
					if flashReadyStatus = STATUS_READY then
						flashWriteEnable <= '1';
						flashReadEnable <= '0';
						flashAddressControl <= "000000000" & addressPtr;
						state <= READ_FLASH_2_WAIT;
					end if;
				
				when READ_FLASH_2_WAIT =>
					flashWriteEnable <= '1';
					flashReadEnable <= '1';
					if flashReadyStatus = STATUS_READY then
						RAMControl.writeEnabled <= FUNC_ENABLED;
						RAMControl.readEnabled <= FUNC_DISABLED;
						RAMControl.address <= "000000000000000000" & (addressPtr - '1');
						-- Warning: watch out for byte order!
						RAMControl.data <= flashDataDisplay & RAMBuffer;
						state <= READ_FLASH_1_COMMAND;
						addressPtr <= addressPtr + '1';
					end if;
					
				when WORK_FINISHED =>
					workFinished <= '1';
					
				when others =>
					state <= READ_FLASH_1_COMMAND;
					addressPtr <= (others => '0');
					workFinished <= '0';
			end case;
		end if;
	end process;
end architecture;
