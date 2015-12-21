OUTPUT_FORMAT("elf32-tradlittlemips")
OUTPUT_ARCH(mips)
ENTRY(_start)

SECTIONS
{
  .text : {
        *(.text)
	*(.rodata)
	*(.rodata1)
	*(.rodata.str1.4)
        }
  . = 0x80000180;
  .text.exception_handler : {
  }

  .reginfo : { *(.reginfo) }

  .date : {
	*(.data)
	}

  .bss  : {
	*(.dynbss)
	*(.bss)
  }
}
