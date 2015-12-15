library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.MIPSCPU.all;
use work.MIPSCP0.all;

entity CP0AddressTranslator is
	port
	(
		tlbData : in CP0TLBData_t;
		virtualAddress : in RAMAddress_t;
		physicsAddress : out RAMAddress_t;
		exceptionTrigger : out CP0ExceptionTrigger_t
	);
end entity;

architecture Behavioral of CP0AddressTranslator is
begin
	process(tlbData, virtualAddress)
		variable tlbEntryFound : boolean;
		variable vpn2 : CP0TLBVPN2_t;
		variable pfn0 : CP0TLBPFN_t;
		variable pfn1 : CP0TLBPFN_t;
		variable pfn : CP0TLBPFN_t;
		variable pageMask : CP0TLBPageMask_t;
		variable evenOddBit : integer := 0;
	begin
		-- TODO : We haven't implement kernel mapped memory segment.
		
		-- Logic address in kernel unmapped memory segment is physics address.
		if virtualAddress(MIPS_RAM_ADDRESS_WIDTH - 1) = '1' then
			physicsAddress <= virtualAddress;
			exceptionTrigger <= (
				enabled => FUNC_DISABLED,
				exceptionCode => (others => 'U')
			);
		else
			for i in 0 to MIPS_CP0_TLB_ENTRY_COUNT - 1 loop
				vpn2 := tlbData(i).entryHigh(
					MIPS_CP0_REGISTER_ENTRY_HIGH_VPN2_HI downto MIPS_CP0_REGISTER_ENTRY_HIGH_VPN2_LO);
				pfn0 := tlbData(i).entryLow0(
					MIPS_CP0_REGISTER_ENTRY_LOW_PFN_HI downto MIPS_CP0_REGISTER_ENTRY_LOW_PFN_LO);
				pfn1 := tlbData(i).entryLow1(
					MIPS_CP0_REGISTER_ENTRY_LOW_PFN_HI downto MIPS_CP0_REGISTER_ENTRY_LOW_PFN_LO);
				pageMask := tlbData(i).pageMask(
					MIPS_CP0_REGISTER_PAGE_MASK_HI downto MIPS_CP0_REGISTER_PAGE_MASK_LO);
				if (vpn2 and not ("000" & pageMask)) = 
					((virtualAddress(MIPS_CP0_REGISTER_ENTRY_HIGH_VPN2_HI downto MIPS_CP0_REGISTER_ENTRY_HIGH_VPN2_LO))
					and not ("000" & pageMask)) then
					case pageMask is
						when "0000000000000000" => evenOddBit := 12;
						when "0000000000000011" => evenOddBit := 14;
						when "0000000000001111" => evenOddBit := 16;
						when "0000000000111111" => evenOddBit := 18;
						when "0000000011111111" => evenOddBit := 20;
						when "0000001111111111" => evenOddBit := 22;
						when "0000111111111111" => evenOddBit := 24;
						when "0011111111111111" => evenOddBit := 26;
						when "1111111111111111" => evenOddBit := 28;
						when others => evenOddBit := 12;--TODO : undefined behaviour.
					end case;
				end if;
				if virtualAddress(evenOddBit) = '0' then
					pfn := pfn0;
				else
					pfn := pfn1;
				end if;
				physicsAddress <= pfn(MIPS_CPU_DATA_WIDTH - 1 - 12 downto evenOddBit - 12) &
					virtualAddress(evenOddBit - 1 downto 0);
			end loop;
		end if;
	end process;

end architecture;

