library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity IPCoreDivider_Testbench is
end entity;

architecture behavior of IPCoreDivider_Testbench is
	component ipcoredivider
	port (
		aclk : in std_logic;
		s_axis_divisor_tvalid : in std_logic;
		s_axis_divisor_tready : out std_logic;
		s_axis_divisor_tdata : in std_logic_vector(39 downto 0);
		s_axis_dividend_tvalid : in std_logic;
		s_axis_dividend_tready : out std_logic;
		s_axis_dividend_tdata : in std_logic_vector(39 downto 0);
		m_axis_dout_tvalid : out std_logic;
		m_axis_dout_tdata : out std_logic_vector(79 downto 0)
	);
	end component;
	signal aclk : std_logic;
	signal s_axis_divisor_tvalid : std_logic;
	signal s_axis_divisor_tready : std_logic;
	signal s_axis_divisor_tdata : std_logic_vector(39 downto 0);
	signal s_axis_dividend_tvalid : std_logic;
	signal s_axis_dividend_tready : std_logic;
	signal s_axis_dividend_tdata : std_logic_vector(39 downto 0);
	signal m_axis_dout_tvalid : std_logic;
	signal m_axis_dout_tuser : std_logic_vector(0 downto 0);
	signal m_axis_dout_tdata : std_logic_vector(79 downto 0);
	constant CPU_CLOCK_PERIOD : time := 20 ns;
	signal clock50M : std_logic;
	begin
		IPCoreDivider_i : component IPCoreDivider
		port map (
			aclk => aclk,
			s_axis_divisor_tvalid => s_axis_divisor_tvalid,
			s_axis_divisor_tready => s_axis_divisor_tready,
			s_axis_divisor_tdata => s_axis_divisor_tdata,
			s_axis_dividend_tvalid => s_axis_dividend_tvalid,
			s_axis_dividend_tready => s_axis_dividend_tready,
			s_axis_dividend_tdata => s_axis_dividend_tdata,
			m_axis_dout_tvalid => m_axis_dout_tvalid,
			m_axis_dout_tdata => m_axis_dout_tdata
		);
  --  Test Bench Statements
	cpuClockProcess : process
	begin
		aclk <= '0';
		wait for CPU_CLOCK_PERIOD/2;
		aclk <= '1';
		wait for CPU_CLOCK_PERIOD/2;
	end process;
	
     tb : PROCESS
     BEGIN
	 	s_axis_divisor_tvalid <= '1';
		s_axis_divisor_tdata <= "0000000000000000000000000000000000110111";
		s_axis_dividend_tvalid <= '1';
		s_axis_dividend_tdata <= "0000000000000100000000000000000010110111";
		wait for 100ns;
		s_axis_divisor_tvalid <= '0';
				s_axis_dividend_tvalid <= '0';
        wait; -- will wait forever
     END PROCESS tb;
  --  End Test Bench 

  END;
