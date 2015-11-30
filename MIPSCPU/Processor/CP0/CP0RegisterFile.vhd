library ieee;
use ieee.std_logic_1164.all;
use work.MIPSCPU.all;
use work.MIPSCP0.all;

entity CP0RegisterFile_c is
    Port (
		reset : in std_logic;
		clock : in std_logic;
        control: in CP0RegisterFileControl_t;
		output : out CP0RegisterFileOutput_t
	);
end entity;

architecture Behavioral of CP0RegisterFile_c is
	component SingleRegister is
	generic (
		width : integer := MIPS_CPU_DATA_WIDTH
	);
	port (
		reset : in std_logic;
		clock : in std_logic;
		input : in  std_logic_vector (width - 1 downto 0);
		operation : in  std_logic;
		output : out  std_logic_vector (width - 1 downto 0)
	);
	end component;
begin
	generate_single_register: for i in 0 to MIPS_CPU_REGISTER_COUNT - 1 generate
	begin
		register_e: component SingleRegister
			port map (
        		reset => reset,
        		clock => clock,
        		input => control(i).data,
        		operation => control(i).operation,
        		output => output(i)
        	);
	end generate generate_single_register;
end architecture;
