library ieee;
use ieee.std_logic_1164.all;

package VirtualHardware is
	constant VIRTUAL_HARDWARE_PRIMARY_RAM_FILE : string
		:= "/mnt/MIPS_EPP_RAMDISK/RAM1.txt";
	constant VIRTUAL_HARDWARE_PRIMARY_RAM_TEMP_FILE : string
		:= "/mnt/MIPS_EPP_RAMDISK/RAM1_Temp.txt";
	constant VIRTUAL_HARDWARE_SECONDARY_RAM_FILE : string
		:= "/mnt/MIPS_EPP_RAMDISK/RAM2.txt";
	constant VIRTUAL_HARDWARE_SECONDARY_RAM_TEMP_FILE : string
		:= "/mnt/MIPS_EPP_RAMDISK/RAM2_Temp.txt";
end package;

package body VirtualHardware is
end package body;
