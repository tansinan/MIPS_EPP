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

  /* $10 stores the address of the UART data register */
  li $10, 0xb40003f8

  /* Register allocations
  $1: Temp
  $2: RAM Starting Address
  $3: RAM Terminate Address
  $4: Checksum
  */

  /* Load the address of RAM to write */
  li $2, 0
  jal wait_for_read
  lbu $1, 0($10)
  addu $2, $0, $1

  jal wait_for_read
  lbu $1, 0($10)
  sll $1, $1, 8
  addu $2, $2, $1

  jal wait_for_read
  lbu $1, 0($10)
  sll $1, $1, 16
  addu $2, $2, $1

  jal wait_for_read
  lbu $1, 0($10)
  sll $1, $1, 24
  addu $2, $2, $1

  /* Write to RAM, 4K each time */
  li $4, 0
  addiu $3, $2, 4096
  write_to_ram:
    write_one_byte:
    	lb $1, 0($10)
    	sb $1, 0($2)
    	addiu $2, $2, 1
    	addu $4, $4, $1
    bne $2, $3, write_to_ram

  /* Write checksum back to serial port */
  jal wait_for_read
  sb $4, 0($10)
  srl $4, 8

  jal wait_for_read
  sb $4, 0($10)
  srl $4, 8

  jal wait_for_read
  sb $4, 0($10)
  srl $4, 8

  jal wait_for_read
  sb $4, 0($10)

  wait_for_write:
    li $16, 0xb40003fC
    not_ready_for_write:
      lw $17, 0($16)
      andi $17, $17, 0x2000
    beqz $17, not_ready_for_write
    jr ra

  wait_for_read:
    li $16, 0xb40003fC
    not_ready_for_read:
      lw $17, 0($16)
      andi $17, $17, 0x100
    beqz $17, not_ready_for_read
    jr ra

END(_start)
