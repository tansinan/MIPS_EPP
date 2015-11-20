library ieee;
use ieee.std_logic_1164.all;
use work.MIPSCPU.all;

entity RegisterFile is
    Port (
		reset : in std_logic;
		clock : in std_logic;
		input : in std_logic_vector (MIPS_CPU_DATA_WIDTH - 1 downto 0);
		operation : in std_logic_vector (MIPS_CPU_REGISTER_COUNT - 1 downto 0);
		output : out mips_register_file_port
	);
end RegisterFile;

architecture Behavioral of RegisterFile is
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
		black_hole_register: if i = 0 generate
		begin
			black_hole_register: component SingleRegister
				port map (reset, clock, input, REGISTER_OPERATION_READ, output(i));
		end generate black_hole_register;
		
		single_register: if i > 0 generate
		begin
			single_register: component SingleRegister
				port map (reset, clock, input, operation(i), output(i));
		end generate single_register;
	end generate generate_single_register;

end Behavioral;

