library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.MIPSCPU.all;
use work.MIPSCP0.all;

entity CP0PipelinePhaseInstructionDecode is
	port (
		reset : in Reset_t;
		clock : in Clock_t;
		instruction : in Instruction_t;
		instructionExecutionEnabled : in EnablingControl_t;
		primaryRegisterFileData : in mips_register_file_port;
		primaryRegisterFileControl : out RegisterFileControl_t;
		cp0RegisterFileData : in CP0RegisterFileOutput_t;
		cp0RegisterFileControl : out CP0RegisterFileControl_t;
		cp0TLBData : in CP0TLBData_t;
		cp0TLBControl: out CP0TLBControl_t;
		pcControl : out RegisterControl_t
	);
end entity;

architecture Behavioral of CP0PipelinePhaseInstructionDecode is
begin
	process(instruction, primaryRegisterFileData, cp0RegisterFileData, instructionExecutionEnabled)
		variable rs, rt: RegisterAddress_t;
		variable rd: CP0RegisterAddress_t;
		variable funct: InstructionFunct_t;
		variable moveAddressPrimaryInt : integer;
		variable moveAddressCP0Int : integer;
	begin
		rs := instruction(MIPS_CPU_INSTRUCTION_RS_HI downto MIPS_CPU_INSTRUCTION_RS_LO);
		rt := instruction(MIPS_CPU_INSTRUCTION_RT_HI downto MIPS_CPU_INSTRUCTION_RT_LO);
		rd := instruction(MIPS_CPU_INSTRUCTION_RD_HI downto MIPS_CPU_INSTRUCTION_RD_LO);
		funct := instruction(MIPS_CPU_INSTRUCTION_FUNCT_HI downto MIPS_CPU_INSTRUCTION_FUNCT_LO);
		moveAddressPrimaryInt := to_integer(unsigned(rt));
		moveAddressCP0Int := to_integer(unsigned(rd));
		if instructionExecutionEnabled = FUNC_DISABLED then
			primaryRegisterFileControl.address <= (others => '0');
			primaryRegisterFileControl.data <= (others => '0');
			for i in 0 to MIPS_CP0_REGISTER_COUNT - 1 loop
				cp0RegisterFileControl(i).data <= (others => '0');
				cp0RegisterFileControl(i).operation <= REGISTER_OPERATION_READ;
			end loop;
			cp0TLBControl.writeEnabled <= FUNC_DISABLED;
			pcControl.operation <= REGISTER_OPERATION_READ;
		elsif rs = MIPS_CP0_INSTRUCTION_RS_MT then
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
			cp0TLBControl.writeEnabled <= FUNC_DISABLED;
			pcControl.operation <= REGISTER_OPERATION_READ;
		elsif rs = MIPS_CP0_INSTRUCTION_RS_MF then
			primaryRegisterFileControl.address <= rt;
			primaryRegisterFileControl.data <= cp0RegisterFileData(moveAddressCP0Int);
			for i in 0 to MIPS_CP0_REGISTER_COUNT - 1 loop
				cp0RegisterFileControl(i).data <= (others => '0');
				cp0RegisterFileControl(i).operation <= REGISTER_OPERATION_READ;
			end loop;
			pcControl.operation <= REGISTER_OPERATION_READ;
			cp0TLBControl.writeEnabled <= FUNC_DISABLED;
		-- TLBWI instruction, update the TLB entry specified by the Index register
		elsif funct = MIPS_CP0_INSTRUCTION_FUNCT_TLBWI then
			primaryRegisterFileControl.address <= (others => '0');
			primaryRegisterFileControl.data <= (others => '0');
			for i in 0 to MIPS_CP0_REGISTER_COUNT - 1 loop
				cp0RegisterFileControl(i).data <= (others => '0');
				cp0RegisterFileControl(i).operation <= REGISTER_OPERATION_READ;
			end loop;
			pcControl.operation <= REGISTER_OPERATION_READ;
			cp0TLBControl <= (
				writeEnabled => FUNC_ENABLED,
				index => cp0RegisterFileData(MIPS_CP0_REGISTER_INDEX_TLB_INDEX)(3 downto 0),
				data => (
					pageMask => cp0RegisterFileData(MIPS_CP0_REGISTER_INDEX_TLB_PAGE_MASK),
					entryHigh => cp0RegisterFileData(MIPS_CP0_REGISTER_INDEX_TLB_ENTRY_HIGH),
					entryLow0 => cp0RegisterFileData(MIPS_CP0_REGISTER_INDEX_TLB_ENTRY_LOW0),
					entryLow1 => cp0RegisterFileData(MIPS_CP0_REGISTER_INDEX_TLB_ENTRY_LOW1)
				)
			);

		-- TLBR instruction, read the TLB entry specified by the Index register
		elsif funct = MIPS_CP0_INSTRUCTION_FUNCT_TLBR then
			primaryRegisterFileControl.address <= (others => '0');
			primaryRegisterFileControl.data <= (others => '0');
			for i in 0 to MIPS_CP0_REGISTER_COUNT - 1 loop
				cp0RegisterFileControl(i).data <= (others => '0');
				cp0RegisterFileControl(i).operation <= REGISTER_OPERATION_READ;
			end loop;
			pcControl.operation <= REGISTER_OPERATION_READ;
			cp0RegisterFileControl(5).operation <= REGISTER_OPERATION_WRITE;
			cp0RegisterFileControl(5).data <= cp0TLBData(to_integer(unsigned(cp0RegisterFileData(0)))).pageMask;
			cp0RegisterFileControl(10).operation <= REGISTER_OPERATION_WRITE;
			cp0RegisterFileControl(10).data <= cp0TLBData(to_integer(unsigned(cp0RegisterFileData(0)))).entryHigh;
			cp0RegisterFileControl(2).operation <= REGISTER_OPERATION_WRITE;
			cp0RegisterFileControl(2).data <= cp0TLBData(to_integer(unsigned(cp0RegisterFileData(0)))).entryLow0;
			cp0RegisterFileControl(3).operation <= REGISTER_OPERATION_WRITE;
			cp0RegisterFileControl(3).data <= cp0TLBData(to_integer(unsigned(cp0RegisterFileData(0)))).entryLow1;
			cp0TLBControl.writeEnabled <= FUNC_DISABLED;

		-- ERET instruction, return from an exception
		elsif funct = MIPS_CP0_INSTRUCTION_FUNCT_ERET then
			for i in 0 to MIPS_CP0_REGISTER_COUNT - 1 loop
				cp0RegisterFileControl(i).operation <= REGISTER_OPERATION_READ;
			end loop;
			cp0TLBControl.writeEnabled <= FUNC_DISABLED;
			primaryRegisterFileControl.address <= (others => '0');
			pcControl <= (
				operation => REGISTER_OPERATION_WRITE,
				data => cp0RegisterFileData(MIPS_CP0_REGISTER_INDEX_EPC)
			);
		end if;
	end process;
end architecture;
