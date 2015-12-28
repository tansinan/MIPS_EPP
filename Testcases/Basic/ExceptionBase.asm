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
	.set	mips2
	.set	reorder
 
/*
In this test case, the following instructions are tested:
LUI, ORI, SW, SB, SU, J
*/
    mfc0 $1, CP0_STATUS
    li $2, 0x400000
    nor $2, $2, $0
    and $1, $1, $2
    mtc0 $1, CP0_STATUS
    
    li $10, 0x80000000
    ori $10, $10, 128

    li $4, 0xd591af37

    sw $4, 1($10)
    
    /**/
    sw $4, 4($10)

    li $25, 0xfd67a120
    li $26, 0x1398de41
    
    sb $25, 1($10)
    sh $26, 2($10)
    sb $25, 4($10)
    sh $26, 5($10)
    
    lw $25, 0($10)
    lw $26, 4($10)
halt:
    j halt
    nop
END(_start)

.section .text.exception_handler
exception_handler:
    li $11, 0x23344556
    halt2:
    j halt2