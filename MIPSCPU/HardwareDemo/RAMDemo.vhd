library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.MIPSCPU.all;
use work.HardwareController.all;

entity RAMDemo is
	port (
		clock : in std_logic;
		reset : in std_logic;
		wrn : out std_logic;
		rdn : out std_logic;
		phyRAMEnable : out std_logic;
		phyRAMWriteEnable : out std_logic;
		phyRAMReadEnable : out std_logic;
		phyAddressBus : out std_logic_vector(PHYSICS_RAM_ADDRESS_WIDTH - 1 downto 0);
		phyDataBus : inout std_logic_vector(PHYSICS_RAM_DATA_WIDTH - 1 downto 0);
		testSucceeded_out : out std_logic
	);
	type RAMDemoState is
	(
		RAM_TEST_STATE_MODE1_WRITE,
		RAM_TEST_STATE_MODE1_READ,
		RAM_TEST_STATE_MODE2_WRITE,
		RAM_TEST_STATE_MODE2_READ,
		RESERVED
	);
end RAMDemo;

architecture Behavioral of RAMDemo is
	signal readControl : RAMReadControl_t;
	signal writeControl : RAMWriteControl_t;
	signal address : std_logic_vector(PHYSICS_RAM_ADDRESS_WIDTH - 1 downto 0);
	signal state : RAMDemoState;
	signal result : std_logic_vector(PHYSICS_RAM_DATA_WIDTH - 1 downto 0);
	signal testSucceeded : std_logic;
	signal clkCnt : std_logic_vector(2 downto 0);
	signal clkDiv : Clock_t;
	signal currentTestedAddress : std_logic_vector(PHYSICS_RAM_ADDRESS_WIDTH - 1 downto 0);
	signal previousTestedAddress : std_logic_vector(PHYSICS_RAM_ADDRESS_WIDTH - 1 downto 0);
begin
	ramController_i : entity work.RAMController_e
	port map (
		clock => clock,
		reset => reset,
		control => (
			readEnabled => readControl.enable,
			writeEnabled => writeControl.enable,
			address => address,
			data => writeControl.data
		),
		result => result,
		physicsRAMControl.enabled => phyRAMEnable,
		physicsRAMControl.writeEnabled => phyRAMWriteEnable,
		physicsRAMControl.readEnabled => phyRAMReadEnable,
		physicsAddressBus => phyAddressBus,
		physicsDataBus => phyDataBus
	);
	wrn <= '1';
	rdn <= '1';
	testSucceeded_out <= testSucceeded;
	process(clock, reset)
	begin
		if reset = FUNC_ENABLED then
			clkCnt <= "000";
		elsif rising_edge(clock) then
			clkCnt <= clkCnt + 1;
		end if;
	end process;
	
	clkDiv <= clkCnt(1);
	
	process(clkDiv, reset)
	begin
		if reset = FUNC_ENABLED then
			state <= RAM_TEST_STATE_MODE1_WRITE;
			currentTestedAddress <= (others => '0');
			previousTestedAddress <= (others => '0');
			testSucceeded <= '1';
		elsif rising_edge(clkDiv) then
			if state = RAM_TEST_STATE_MODE1_WRITE then
				if currentTestedAddress(0) /= previousTestedAddress(0) and
					result /= 
						(not previousTestedAddress(19 downto 8)) & previousTestedAddress(19 downto 0)
					then
						testSucceeded <= '0';
						--state <= RESERVED;
				end if;
				--else
				if previousTestedAddress /= "11111111111111111111" then
					readControl.enable <= '1';
					writeControl.enable <= '0';
					address <= currentTestedAddress;
					writeControl.data <=
						(not currentTestedAddress(19 downto 8)) & currentTestedAddress(19 downto 0);
					state <= RAM_TEST_STATE_MODE1_READ;
				else
					state <= RAM_TEST_STATE_MODE2_WRITE;
					currentTestedAddress <= (others => '0');
					previousTestedAddress <= (others => '0');
				end if;
				--end if;
			elsif state = RAM_TEST_STATE_MODE1_READ then
				readControl.enable <= '0';
				writeControl.enable <= '1';
				address <= currentTestedAddress;
				currentTestedAddress <= currentTestedAddress + 1;
				previousTestedAddress <= currentTestedAddress;
				state <= RAM_TEST_STATE_MODE1_WRITE;
			elsif state = RAM_TEST_STATE_MODE2_WRITE then
				if currentTestedAddress /= "11111111111111111111" then
					readControl.enable <= '1';
					writeControl.enable <= '0';
					address <= currentTestedAddress;
					writeControl.data <=
						currentTestedAddress(19 downto 8) & not currentTestedAddress(19 downto 0);
					state <= RAM_TEST_STATE_MODE2_WRITE;
					currentTestedAddress <= currentTestedAddress + 1;
				else
					currentTestedAddress <= (others => '0');
					previousTestedAddress <= (others => '0');
					state <= RAM_TEST_STATE_MODE2_READ;
				end if;
			elsif state = RAM_TEST_STATE_MODE2_READ then
				readControl.enable <= '0';
				writeControl.enable <= '1';
				address <= currentTestedAddress;
				currentTestedAddress <= currentTestedAddress + 1;
				previousTestedAddress <= currentTestedAddress;
				state <= RAM_TEST_STATE_MODE2_READ;
				if currentTestedAddress(0) /= previousTestedAddress(0) and
				result /=
					previousTestedAddress(19 downto 8) & not previousTestedAddress(19 downto 0) then
					testSucceeded <= '0';
					state <= RESERVED;
				elsif currentTestedAddress = "11111111111111111111" then
					currentTestedAddress <= (others => '0');
					previousTestedAddress <= (others => '0');
					state <= RAM_TEST_STATE_MODE1_WRITE;
				end if;
			end if;
		end if;
	end process;
end architecture;

