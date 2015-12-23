library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

  ENTITY testbench IS
  END testbench;

  ARCHITECTURE behavior OF testbench IS 

  -- Component Declaration
COMPONENT IPCoreDivider
  PORT (
    aclk : IN STD_LOGIC;
    s_axis_divisor_tvalid : IN STD_LOGIC;
    s_axis_divisor_tready : OUT STD_LOGIC;
    s_axis_divisor_tdata : IN STD_LOGIC_VECTOR(39 DOWNTO 0);
    s_axis_dividend_tvalid : IN STD_LOGIC;
    s_axis_dividend_tready : OUT STD_LOGIC;
    s_axis_dividend_tdata : IN STD_LOGIC_VECTOR(39 DOWNTO 0);
    m_axis_dout_tvalid : OUT STD_LOGIC;
    m_axis_dout_tuser : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    m_axis_dout_tdata : OUT STD_LOGIC_VECTOR(71 DOWNTO 0)
  );
END COMPONENT;
	 signal cpu_clock_period : STD_LOGIC;
    signal s_axis_divisor_tvalid : STD_LOGIC;
    signal s_axis_divisor_tready : STD_LOGIC;
    signal s_axis_divisor_tdata : STD_LOGIC_VECTOR(39 DOWNTO 0);
    signal s_axis_dividend_tvalid : STD_LOGIC;
    signal s_axis_dividend_tready : STD_LOGIC;
    signal s_axis_dividend_tdata : STD_LOGIC_VECTOR(39 DOWNTO 0);
    signal m_axis_dout_tvalid : STD_LOGIC;
    signal m_axis_dout_tuser : STD_LOGIC_VECTOR(0 DOWNTO 0);
    signal m_axis_dout_tdata : STD_LOGIC_VECTOR(71 DOWNTO 0);
	 	-- clock period definitions
	constant CLOCK_PERIOD : time := 20 ns;
	signal clock50M : std_logic := '0';

  BEGIN

your_instance_name : IPCoreDivider
  PORT MAP (
    aclk => clock50M,
    s_axis_divisor_tvalid => s_axis_divisor_tvalid,
    s_axis_divisor_tready => s_axis_divisor_tready,
    s_axis_divisor_tdata => s_axis_divisor_tdata,
    s_axis_dividend_tvalid => s_axis_dividend_tvalid,
    s_axis_dividend_tready => s_axis_dividend_tready,
    s_axis_dividend_tdata => s_axis_dividend_tdata,
    m_axis_dout_tvalid => m_axis_dout_tvalid,
    m_axis_dout_tuser => m_axis_dout_tuser,
    m_axis_dout_tdata => m_axis_dout_tdata
  );


  --  Test Bench Statements
     tb : PROCESS
     BEGIN
		s_axis_divisor_tvalid <= '0';
		s_axis_divisor_tdata <= "0000000000000000000000000000000001011010";
		s_axis_dividend_tvalid <= '0';
		s_axis_dividend_tdata <= "0000000000000000000000000000000000000011";
		wait; -- will wait forever
     END PROCESS tb;
	  
	cpuClockProcess : process
	begin
		clock50M <= '0';
		wait for CLOCK_PERIOD/2;
		clock50M <= '1';
		wait for CLOCK_PERIOD/2;
	end process;
  END;
