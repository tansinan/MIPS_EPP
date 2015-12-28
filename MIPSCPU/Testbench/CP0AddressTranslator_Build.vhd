library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.MIPSCPU.all;
use work.MIPSCP0.all;

entity CP0AddressTranslator_Build is
end CP0AddressTranslator_Build;

architecture behavior of CP0AddressTranslator_Build is
	signal tlbData : CP0TLBData_t;
	signal virtualAddress : RAMAddress_t;
	signal physicsAddress : RAMAddress_t;
	signal exceptionTriggerOut : CP0ExceptionTrigger_t;
 
BEGIN
    addr: entity work.CP0AddressTranslator
	port map
	(
		tlbData => tlbData,
		virtualAddress => virtualAddress,
		physicsAddress => physicsAddress,
		exceptionTriggerOut => exceptionTriggerOut,
		instructionOpcode => (others => '0')
	);  

   -- Stimulus process
   stim_proc: process
   begin
		for i in 0 to MIPS_CP0_TLB_ENTRY_COUNT - 1 loop
			tlbData(i) <= (
				pageMask => x"00000000",
				entryHigh => x"00000000",
				entryLow0 => x"0000ff17",
				entryLow1 => x"0000ff17"
			);
		end loop;
		virtualAddress <= x"00000100";
      wait;
   end process;

END;
