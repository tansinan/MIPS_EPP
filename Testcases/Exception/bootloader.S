/*
 * This is a bootloader for our MIPS_EPP project
 * Note : MUST COMPILE WITH NO BRANCH DELAY SLOT OPTION ON!
 */

#include "regdef.h"
#include "cp0regdef.h"
#include "asm.h"

LEAF(_start)
  .set mips32
  .set reorder
  .set noat

  li $10, 0xb40003f8
  li $16, 0xFF
  lw $15, 0($10)
  sb $16, 1($10)
  lw $15, 0($10)
  #stop:
  #b stop
  li $1, 0x1000000
  mtc0 $1, CP0_COMPARE
  mtc0 $0, CP0_COUNT

  mfc0 $2, CP0_STATUS
  li $1, 0x400004
  nor $1, $1, $0
  and $2, $2, $1
  mtc0 $2, CP0_STATUS

  li $2, 0xFC01
  mfc0 $1, CP0_STATUS
  or $1, $1, $2
  mtc0 $1, CP0_STATUS
  #li $1, 0x80000000
  #lw $1, 1($1)

  halt:
  j halt

END(_start)

.section .text.exception_handler
li $16, 0xFF
sb $16, 1($10)
li $11, 'A'
sw $11, 0($10)
mtc0 $0, CP0_COUNT
li $1, 0x1000000
mtc0 $1, CP0_COMPARE
eret
#halt2:
#   mfc0 $10, CP0_COUNT
#   mfc0 $11, CP0_COMPARE
#j halt2
