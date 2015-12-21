library ieee;
use ieee.std_logic_1164.all;
use work.MIPSCPU.all;

package MIPSCP0 is

	-- Constants and (sub)types related to the CP0 register file
	-- The address width of the registers in CP0
	constant MIPS_CP0_REGISTER_ADDRESS_WIDTH: integer := 5;

	-- The number of registers in CP0
	constant MIPS_CP0_REGISTER_COUNT: integer := 2**MIPS_CPU_REGISTER_ADDRESS_WIDTH;
	subtype CP0RegisterAddress_t is
		std_logic_vector(MIPS_CP0_REGISTER_ADDRESS_WIDTH - 1 downto 0);

	type CP0RegisterFileOutput_t is
		array(0 to MIPS_CP0_REGISTER_COUNT - 1) of CPUData_t;

	type CP0RegisterFileControl_t is
		array(0 to MIPS_CP0_REGISTER_COUNT - 1) of RegisterControl_t;
		
	constant MIPS_CP0_REGISTER_INDEX_TLB_INDEX : integer := 0;
	constant MIPS_CP0_REGISTER_INDEX_TLB_ENTRY_LOW0 : integer := 2;
	constant MIPS_CP0_REGISTER_INDEX_TLB_ENTRY_LOW1 : integer := 3;
	constant MIPS_CP0_REGISTER_INDEX_TLB_PAGE_MASK : integer := 5;
	constant MIPS_CP0_REGISTER_INDEX_COUNT : integer := 9;
	constant MIPS_CP0_REGISTER_INDEX_TLB_ENTRY_HIGH : integer := 10;
	constant MIPS_CP0_REGISTER_INDEX_COMPARE : integer := 11;
	constant MIPS_CP0_REGISTER_INDEX_STATUS : integer := 12;
	constant MIPS_CP0_REGISTER_INDEX_CAUSE : integer := 13;
	constant MIPS_CP0_REGISTER_INDEX_EPC : integer := 14;
	
	constant MIPS_CP0_REGISTER_PAGE_MASK_HI : integer := 28;
	constant MIPS_CP0_REGISTER_PAGE_MASK_LO : integer := 13;
	constant MIPS_CP0_REGISTER_PAGE_MASK_WIDTH : integer := 
		MIPS_CP0_REGISTER_PAGE_MASK_HI - MIPS_CP0_REGISTER_PAGE_MASK_LO + 1;
	subtype CP0TLBPageMask_t is
		std_logic_vector(MIPS_CP0_REGISTER_PAGE_MASK_WIDTH - 1 downto 0);
		
	constant MIPS_CP0_REGISTER_ENTRY_HIGH_VPN2_HI : integer := 31;
	constant MIPS_CP0_REGISTER_ENTRY_HIGH_VPN2_LO : integer := 13;
	constant MIPS_CP0_REGISTER_ENTRY_HIGH_VPN2_WIDTH : integer := 
		MIPS_CP0_REGISTER_ENTRY_HIGH_VPN2_HI - MIPS_CP0_REGISTER_ENTRY_HIGH_VPN2_LO + 1;
	subtype CP0TLBVPN2_t is
		std_logic_vector(MIPS_CP0_REGISTER_ENTRY_HIGH_VPN2_WIDTH - 1 downto 0);
		
	constant MIPS_CP0_REGISTER_ENTRY_LOW_PFN_HI : integer := 29;
	constant MIPS_CP0_REGISTER_ENTRY_LOW_PFN_LO : integer := 6;
	constant MIPS_CP0_REGISTER_ENTRY_LOW_PFN_WIDTH : integer := 
		MIPS_CP0_REGISTER_ENTRY_LOW_PFN_HI - MIPS_CP0_REGISTER_ENTRY_LOW_PFN_LO + 1;
	subtype CP0TLBPFN_t is
		std_logic_vector(MIPS_CP0_REGISTER_ENTRY_LOW_PFN_WIDTH - 1 downto 0);
	
	constant MIPS_CP0_REGISTER_ENTRY_LOW_DIRTY : integer := 2;
	constant MIPS_CP0_REGISTER_ENTRY_LOW_VALID : integer := 1;
	constant MIPS_CP0_REGISTER_ENTRY_LOW_GLOBAL : integer := 0;
	
	constant MIPS_CP0_CAUSE_EXCEPTION_CODE_HI : integer := 6;
	constant MIPS_CP0_CAUSE_EXCEPTION_CODE_LO : integer := 2;
	constant MIPS_CP0_CAUSE_EXCEPTION_CODE_WIDTH : integer := 
		MIPS_CP0_CAUSE_EXCEPTION_CODE_HI - MIPS_CP0_CAUSE_EXCEPTION_CODE_LO + 1;
	
	constant MIPS_CP0_CAUSE_INTERRUPT_PENDING_HI : integer := 15;
	constant MIPS_CP0_CAUSE_INTERRUPT_PENDING_LO : integer := 10;
	constant MIPS_CP0_CAUSE_INTERRUPT_PENDING_WIDTH : integer := 
		MIPS_CP0_CAUSE_INTERRUPT_PENDING_HI - MIPS_CP0_CAUSE_INTERRUPT_PENDING_LO + 1;
	
	constant MIPS_CP0_STATUS_ERL : integer := 2;
	constant MIPS_CP0_STATUS_EXL : integer := 1;
	
	subtype CP0CauseExceptionCode_t is
		std_logic_vector(MIPS_CP0_CAUSE_EXCEPTION_CODE_WIDTH - 1 downto 0);

	constant MIPS_CP0_CAUSE_EXCEPTION_CODE_INTERRUPT :
		CP0CauseExceptionCode_t := "00000";

	constant MIPS_CP0_CAUSE_EXCEPTION_CODE_TLB_MODIFICATION :
		CP0CauseExceptionCode_t := "00001";
		
	constant MIPS_CP0_CAUSE_EXCEPTION_CODE_TLB_LOAD :
		CP0CauseExceptionCode_t := "00010";

	constant MIPS_CP0_CAUSE_EXCEPTION_CODE_TLB_STORE :
		CP0CauseExceptionCode_t := "00011";
	
	constant MIPS_CP0_CAUSE_EXCEPTION_CODE_ADDRESS_LOAD :
		CP0CauseExceptionCode_t := "00100";

	constant MIPS_CP0_CAUSE_EXCEPTION_CODE_ADDRESS_STORE :
		CP0CauseExceptionCode_t := "00101";
	
	constant MIPS_CP0_CAUSE_EXCEPTION_CODE_BUS_LOAD :
		CP0CauseExceptionCode_t := "00110";

	constant MIPS_CP0_CAUSE_EXCEPTION_CODE_BUS_STORE :
		CP0CauseExceptionCode_t := "00111";
	
	constant MIPS_CP0_CAUSE_EXCEPTION_CODE_SYSCALL :
		CP0CauseExceptionCode_t := "01000";

	constant MIPS_CP0_TLB_INDEX_WIDTH : integer := 4;
	constant MIPS_CP0_TLB_ENTRY_COUNT : integer := 2**MIPS_CP0_TLB_INDEX_WIDTH;
	subtype CP0TLBEntryIndex_t is
		std_logic_vector(MIPS_CP0_TLB_INDEX_WIDTH - 1 downto 0);


	-- Constant and (sub)types related to CP0 TLB
	type CP0TLBEntry_t is
		record
			pageMask : CPUData_t;
			entryHigh : CPUData_t;
			entryLow0 : CPUData_t;
			entryLow1 : CPUData_t;
		end record;

	type CP0TLBData_t is
		array(0 to MIPS_CP0_TLB_ENTRY_COUNT - 1) of CP0TLBEntry_t;

	type CP0TLBControl_t is
		record
			data : CP0TLBEntry_t;
			index : CP0TLBEntryIndex_t;
			writeEnabled : std_logic;
		end record;
	
	-- Constant and (sub)types related to interrupt handling
	type CP0ExceptionTrigger_t is
		record
			enabled : EnablingControl_t;
			exceptionCode : CP0CauseExceptionCode_t;
			badVirtualAddress : RAMAddress_t;
		end record;
		
	constant MIPS_CP0_HARDWARE_INTERRUPT_COUNT : integer := 6;
	subtype CP0InterruptCodeMask_t is
		std_logic_vector(MIPS_CP0_HARDWARE_INTERRUPT_COUNT - 1 downto 0);
	type CP0HardwareInterruptTrigger_t is
		record
			enabled : EnablingControl_t;
			interruptCodeMask : CP0InterruptCodeMask_t;
		end record;
		
	constant MIPS_CP0_INTERNAL_INTERRUPT_SOURCE_COUNT : integer := 1;
	constant MIPS_CP0_EXTERNAL_INTERRUPT_SOURCE_COUNT : integer := 1;
	constant MIPS_CP0_INTERRUPT_SOURCE_COUNT : integer := 
		MIPS_CP0_INTERNAL_INTERRUPT_SOURCE_COUNT +
		MIPS_CP0_EXTERNAL_INTERRUPT_SOURCE_COUNT;
	type CP0InterruptSource_t is
		array(0 to MIPS_CP0_INTERRUPT_SOURCE_COUNT - 1) of 
		CP0HardwareInterruptTrigger_t;
	type CP0InternalInterruptSource_t is
		array(0 to MIPS_CP0_INTERNAL_INTERRUPT_SOURCE_COUNT - 1) of 
		CP0HardwareInterruptTrigger_t;
	type CP0ExternalInterruptSource_t is
		array(0 to MIPS_CP0_EXTERNAL_INTERRUPT_SOURCE_COUNT - 1) of 
		CP0HardwareInterruptTrigger_t;

	-- Constants related to CP0 instructions
	constant MIPS_CP0_INSTRUCTION_RS_MF : RegisterAddress_t := "00000";
	constant MIPS_CP0_INSTRUCTION_RS_MT : RegisterAddress_t := "00100";
	
	constant MIPS_CP0_INSTRUCTION_FUNCT_ERET : InstructionFunct_t := "011000";
	constant MIPS_CP0_INSTRUCTION_FUNCT_TLBWI : InstructionFunct_t := "000010";
	constant MIPS_CP0_INSTRUCTION_FUNCT_TLBR : InstructionFunct_t := "000001";
	constant MIPS_CP0_INSTRUCTION_FUNCT_SYSCALL : InstructionFunct_t := "001100";
	
	constant MIPS_CP0_NONBOOT_EXCEPTION_HANDLER : RAMAddress_t := x"80000180";

end package;

package body MIPSCP0 is
end package body;
