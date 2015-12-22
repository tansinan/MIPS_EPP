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
		pcControl : out RegisterControl_t;
		exceptionTriggerOut : out CP0ExceptionTrigger_t;
		compareRegisterModified : out EnablingControl_t
	);
end entity;

architecture Behavioral of CP0PipelinePhaseInstructionDecode is
	signal exceptionTrigger : CP0ExceptionTrigger_t;
begin
	process(instruction, primaryRegisterFileData, 
	cp0RegisterFileData, instructionExecutionEnabled, cp0TLBData)
		variable rs, rt: RegisterAddress_t;
		variable rd: CP0RegisterAddress_t;
		variable funct: InstructionFunct_t;
		variable moveAddressPrimaryInt : integer;
		variable moveAddressCP0Int : integer;
		variable causeTemp : CPUData_t;
		variable statusTemp : CPUData_t;
	begin
		-- Store related data to variables
		rs := instruction(MIPS_CPU_INSTRUCTION_RS_HI downto MIPS_CPU_INSTRUCTION_RS_LO);
		rt := instruction(MIPS_CPU_INSTRUCTION_RT_HI downto MIPS_CPU_INSTRUCTION_RT_LO);
		rd := instruction(MIPS_CPU_INSTRUCTION_RD_HI downto MIPS_CPU_INSTRUCTION_RD_LO);
		funct := instruction(MIPS_CPU_INSTRUCTION_FUNCT_HI downto MIPS_CPU_INSTRUCTION_FUNCT_LO);
		moveAddressPrimaryInt := to_integer(unsigned(rt));
		moveAddressCP0Int := to_integer(unsigned(rd));
		exceptionTrigger <= (
			enabled => FUNC_DISABLED,
			exceptionCode => (others => '0'),
			badVirtualAddress => (others => '0')
		);
		causeTemp := cp0RegisterFileData(MIPS_CP0_REGISTER_INDEX_CAUSE);
		statusTemp := cp0RegisterFileData(MIPS_CP0_REGISTER_INDEX_STATUS);
		
		-- Let nothing to be done on default state
		
		-- No timer interrupt reset (compare register modified)
		compareRegisterModified <= FUNC_DISABLED;
		
		-- Disable primary register file control
		primaryRegisterFileControl <= (
			address => (others => '0'),
			data => (others => '0')
		);
		-- Disable CP0 Register file control
		for i in 0 to MIPS_CP0_REGISTER_COUNT - 1 loop
			cp0RegisterFileControl(i) <= (
				operation => REGISTER_OPERATION_READ,
				data => (others => '0')
			);
		end loop;
		-- Disable TLB Controls
		cp0TLBControl <= (
			writeEnabled => FUNC_DISABLED,
			index => (others => '0'),
			data => (
				pageMask => (others => '0'),
				entryHigh => (others => '0'),
				entryLow0 => (others => '0'),
				entryLow1 => (others => '0')
			)
		);
		-- Disable PC Controls
		pcControl <= (
			operation => REGISTER_OPERATION_READ,
			data => (others => '0')
		);
		
		if instructionExecutionEnabled = FUNC_DISABLED then

			cp0TLBControl.writeEnabled <= FUNC_DISABLED;
			pcControl.operation <= REGISTER_OPERATION_READ;
			
		-- MTC0 instruction
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
			if moveAddressCP0Int = MIPS_CP0_REGISTER_INDEX_COMPARE then
				compareRegisterModified <= FUNC_ENABLED;
			end if;
			
		-- MFC0 instruction
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
			statusTemp(MIPS_CP0_STATUS_ERL) := '0';
			statusTemp(MIPS_CP0_STATUS_EXL) := '0';
			cp0RegisterFileControl(MIPS_CP0_REGISTER_INDEX_STATUS) <= (
				operation => REGISTER_OPERATION_WRITE,
				data => statusTemp
			);

		-- SYSCALL instruction
		elsif funct = MIPS_CP0_INSTRUCTION_FUNCT_SYSCALL then
			for i in 0 to MIPS_CP0_REGISTER_COUNT - 1 loop
				cp0RegisterFileControl(i).operation <= REGISTER_OPERATION_READ;
			end loop;
			cp0TLBControl.writeEnabled <= FUNC_DISABLED;
			exceptionTrigger <= (
				enabled => FUNC_ENABLED,
				exceptionCode => MIPS_CP0_CAUSE_EXCEPTION_CODE_SYSCALL,
				badVirtualAddress => (others => '0')
			);
		else
			for i in 0 to MIPS_CP0_REGISTER_COUNT - 1 loop
				cp0RegisterFileControl(i).operation <= REGISTER_OPERATION_READ;
			end loop;
			cp0TLBControl.writeEnabled <= FUNC_DISABLED;
			primaryRegisterFileControl.address <= (others => '0');
			cp0TLBControl.writeEnabled <= FUNC_DISABLED;
		end if;
	end process;
	exceptionTriggerOut <= exceptionTrigger;
end architecture;
