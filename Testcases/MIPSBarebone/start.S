
/*
 * Copyright (C) 2001 MontaVista Software Inc.
 * Author: Jun Sun, jsun@mvista.com or jsun@junsun.net
 *
 * This program is free software; you can redistribute  it and/or modify it
 * under  the terms of  the GNU General  Public License as published by the
 * Free Software Foundation;  either version 2 of the  License, or (at your
 * option) any later version.
 *
 */

#include "regdef.h"
#include "cp0regdef.h"
#include "asm.h"

LEAF(_start)

	.set	mips32
	.set	reorder

  li $10, 0xb40003f8
  jal wait_for_write
  li $11, 'H'
sw $11, 0($10)
	/* Disable interrupts */
	mtc0	zero, CP0_STATUS

        /* Disable watch exception. */
        mtc0    zero, CP0_WATCHLO
        mtc0    zero, CP0_WATCHHI

	/* disable kernel mode cache */
	mfc0	t0, CP0_CONFIG
	and	t0, ~0x7
	ori	t0, 0x2
	mtc0	t0, CP0_CONFIG

	/* set up stack */
	#li	sp, 0x80000000 + 10240 - 16
  bal bbbb
	/* jump to main */
	jal	main
bbbb:
li      sp, 0x80000000 + 10240 - 16
nop
jr ra

loop:
	j	loop
	nop
END(_start)

wait_for_write:
  li $16, 0xb40003fC
  not_ready_for_write:
      lw $17, 0($16)
      andi $17, $17, 0x2000
  beqz $17, not_ready_for_write
  jr ra
