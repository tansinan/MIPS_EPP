library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.MIPSCPU.all;
use work.MIPSCP0.all;

entity CP0PipelinePhaseInstructionDecode is
	port (
		reset : in std_logic;
		clock : in std_logic;
		instruction : in Instruction_t;
		primaryRegisterFileData : in mips_register_file_port;
		primaryRegisterFileControl : out RegisterFileControl_t;
		cp0RegisterFileData : in CP0RegisterFileOutput_t;
		cp0RegisterFileControl : out CP0RegisterFileControl_t
	);
end entity;

architecture Behavioral of CP0PipelinePhaseInstructionDecode is
begin
	process(instruction, primaryRegisterFileData, cp0RegisterFileData)
		variable rs, rt: RegisterAddress_t;
		variable rd : CP0RegisterAddress_t;
		variable moveAddressPrimaryInt : integer;
		variable moveAddressCP0Int : integer;
	begin
		rs := instruction(MIPS_CPU_INSTRUCTION_RS_HI downto MIPS_CPU_INSTRUCTION_RS_LO);
		rt := instruction(MIPS_CPU_INSTRUCTION_RT_HI downto MIPS_CPU_INSTRUCTION_RT_LO);
		rd := instruction(MIPS_CPU_INSTRUCTION_RD_HI downto MIPS_CPU_INSTRUCTION_RD_LO);
		moveAddressPrimaryInt := to_integer(unsigned(rt));
		moveAddressCP0Int := to_integer(unsigned(rd));
		if rs = MIPS_CP0_INSTRUCTION_RS_MT then
			for i in 0 to MIPS_CP0_REGISTER_COUNT - 1 loop
				if i = moveAddressCP0Int then
					cp0RegisterFileControl(i).data <= primaryRegisterFileData(moveAddressPrimaryInt);
					cp0RegisterFileControl(i).operation <= REGISTER_OPERATION_WRITE;
				else
					cp0RegisterFileControl(i).data <= (others => '0');
					cp0RegisterFileControl(i).operation <= REGISTER_OPERATION_READ;
				end if;
			end loop;
			primaryRegisterFileControl.address <= (others => '0');
			primaryRegisterFileControl.data <= (others => '0');
		elsif rs = MIPS_CP0_INSTRUCTION_RS_MF then
			primaryRegisterFileControl.address <= rt;
			primaryRegisterFileControl.data <= cp0RegisterFileData(moveAddressCP0Int);
			for i in 0 to MIPS_CP0_REGISTER_COUNT - 1 loop
				cp0RegisterFileControl(i).data <= (others => '0');
				cp0RegisterFileControl(i).operation <= REGISTER_OPERATION_READ;
			end loop;
		end if;
	end process;
end architecture;
