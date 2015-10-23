library ieee;
use ieee.std_logic_1164.all;

package MIPSCPU is
	constant ALU_OPERATION_CTRL_WIDTH : integer := 5;
	constant ALU_OPERATION_ADD : 
		std_logic_vector(ALU_OPERATION_CTRL_WIDTH - 1 downto 0) := "00000";
	constant ALU_OPERATION_SUBTRACT : 
		std_logic_vector(ALU_OPERATION_CTRL_WIDTH - 1 downto 0) := "00001";
	constant ALU_OPERATION_LOGIC_AND : 
		std_logic_vector(ALU_OPERATION_CTRL_WIDTH - 1 downto 0) := "00010";
	constant ALU_OPERATION_LOGIC_OR : 
		std_logic_vector(ALU_OPERATION_CTRL_WIDTH - 1 downto 0) := "00011";
end MIPSCPU;

package body MIPSCPU is
end MIPSCPU;
