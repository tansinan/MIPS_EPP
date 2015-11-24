library ieee;
use ieee.std_logic_1164.all;
use work.mipscpu.all;

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
		phyDataBus : inout std_logic_vector(PHYSICS_RAM_DATA_WIDTH - 1 downto 0)
	);
end RAMDemo;

architecture Behavioral of RAMDemo is
	component RAMController_c is
	port (
		clock : in std_logic;
		reset : in std_logic;
		readControl1 : in RAMReadControl_t;
		readControl2 : in RAMReadControl_t;
		writeControl : in RAMWriteControl_t;
		result : out std_logic_vector(PHYSICS_RAM_DATA_WIDTH - 1 downto 0);
		phyRAMEnable : out std_logic;
		phyRAMWriteEnable : out std_logic;
		phyRAMReadEnable : out std_logic;
		phyAddressBus : out std_logic_vector(PHYSICS_RAM_ADDRESS_WIDTH - 1 downto 0);
		phyDataBus : inout std_logic_vector(PHYSICS_RAM_DATA_WIDTH - 1 downto 0)
	);
	end component;
	signal readControl1 : RAMReadControl_t;
	signal readControl2 : RAMReadControl_t;
	signal writeControl : RAMWriteControl_t;
	signal state : std_logic_vector(3 downto 0);
	signal result : std_logic_vector(PHYSICS_RAM_DATA_WIDTH - 1 downto 0);
begin
	ramController_e : RAMController_c port map (
		clock => clock,
		reset => reset,
		readControl1 => readControl1,
		readControl2 => readCOntrol2,
		writeControl => writeControl,
		result => result,
		phyRAMEnable => phyRAMEnable,
		phyRAMWriteEnable => phyRAMWriteEnable,
		phyRAMReadEnable => phyRAMReadEnable,
		phyAddressBus => phyAddressBus,
		phyDataBus => phyDataBus
	);
	wrn <= '1';
	rdn <= '1';
	process(clock, reset)
	begin
		if reset = '0' then
			state <= "0000";
			readControl1.enable <= '1';
			readControl2.enable <= '1';
			writeControl.enable <= '1';
		elsif rising_edge(clock) then
			if state = "0000" then
				readControl1.enable <= '1';
				readControl2.enable <= '1';
				writeControl.enable <= '0';
				writeControl.address <= "00000000000000000000";
				writeControl.data <= "00010001000100010001000100010001";
				state <= "0001";
			elsif state = "0001" then
				readControl1.enable <= '1';
				readControl2.enable <= '1';
				writeControl.enable <= '0';
				writeControl.address <= "00000000000000000001";
				writeControl.data <= "00110011001100110011001100110011";
				state <= "1010";
			elsif state = "1010" then
				readControl1.enable <= '0';
				readControl2.enable <= '1';
				writeControl.enable <= '1';
				readControl1.address <= "00000000000000000010";
				state <= "0010";
			elsif state = "0010" then
				readControl1.enable <= '1';
				readControl2.enable <= '1';
				writeControl.enable <= '0';
				writeControl.address <= "00000000000000000010";
				writeControl.data <= "01110111011101110111011101110111";
				state <= "0011";
			elsif state = "0011" then
				state <= "0100";
			elsif state = "0100" then
				readControl1.enable <= '0';
				readControl2.enable <= '1';
				writeControl.enable <= '1';
				readControl1.address <= "00000000000000000001";
			else
			end if;		
		end if;
	end process;
end architecture;
