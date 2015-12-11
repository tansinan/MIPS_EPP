library ieee;
use ieee.std_logic_1164.all;
use work.MIPSCPU.all;
use work.MIPSCP0.all;

entity CP0RegisterFile_c is
    Port (
		reset : in std_logic;
		clock : in std_logic;
        control0: in CP0RegisterFileControl_t;
		control1 : in CP0RegisterFileControl_t;
		output : out CP0RegisterFileOutput_t
	);
end entity;

architecture Behavioral of CP0RegisterFile_c is
	signal usedControl : CP0RegisterFileControl_t;
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
	-- This process 
	process(control0, control1)
	begin
		for i in 0 to MIPS_CP0_REGISTER_COUNT - 1 loop
			if control0(i).operation = REGISTER_OPERATION_WRITE then
				usedControl(i) <= control0(i);
			else
				usedControl(i) <= control1(i);
			end if;
			if control0(i).operation = REGISTER_OPERATION_WRITE and
				control1(i).operation = REGISTER_OPERATION_WRITE then
				report "Warning : confliction in CP0 register operation detected!";
			end if;
		end loop;
	end process;
	
	generate_single_register: for i in 0 to MIPS_CPU_REGISTER_COUNT - 1 generate
	begin
		register_e: component SingleRegister
			port map (
        		reset => reset,
        		clock => clock,
        		input => usedControl(i).data,
        		operation => usedControl(i).operation,
        		output => output(i)
        	);
	end generate;
end architecture;
