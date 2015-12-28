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
  $2: Writing Starting Address
  $3: Writing Terminate Address
  $4: Checksum
	$5: Mode Switch, 0: to RAM 1: flash to RAM 2: to flash
	$6: Reading Starting Address(Temp 2 when not used as RSA)
  */

  load_address:
		/* Load Mode Switch */
		jal wait_for_read
    lbu $1, 0($10)
		addu $5, $0, $1
  
		/* Load the address to write */
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

    /* Jump to OS entry if address is 0 */
    beq $2, $0, jump_to_os_entry
		
		/* Jump to Flash to RAM if Mode Switch is 0 */
		beq $5, $0, write_to_ram
		
		/* Jump to Flash to RAM if Mode Switch is 1 */
		addiu $1, $0, 1
		beq $5, $1, flash_to_ram
		
		/* Jump to write to Flash if Mode Switch is 2 */
		addiu $1, $1, 1
		beq $5, $1, write_to_flash

    write_to_ram:
    /* Write to RAM, 4K each time */
    #li $4, 0
    addiu $3, $2, 4096
      write_one_byte_ram:
      jal wait_for_read
      lbu $1, 0($10)
      sb $1, 0($2)
      lb $1, 0($2)
      jal wait_for_write
      sb $1, 0($10)
      addiu $2, $2, 1
      #addu $4, $4, $1
      bne $2, $3, write_one_byte_ram

    move $3, $4
    /* Write checksum back to serial port */
    #jal wait_for_write
    #sw $4, 0($10)
    #srl $4, 8

    #jal wait_for_write
    #sw $4, 0($10)
    #srl $4, 8

    #jal wait_for_write
    #sw $4, 0($10)
    #srl $4, 8

    #jal wait_for_write
    #sw $4, 0($10)

  /* Back to the beginning */
  j load_address

	flash_to_ram:
    /* Move from Flash to RAM, 4K each time */
		/* Load the address of Flash to read */
    li $6, 0
    jal wait_for_read
    lbu $1, 0($10)
    addu $6, $0, $1

    jal wait_for_read
    lbu $1, 0($10)
    sll $1, $1, 8
    addu $6, $6, $1

    jal wait_for_read
    lbu $1, 0($10)
    sll $1, $1, 16
    addu $6, $6, $1

    jal wait_for_read
    lbu $1, 0($10)
    sll $1, $1, 24
    addu $6, $6, $1
		
		/* Start moving data from Flash to RAM */
    addiu $3, $2, 4096
		sll $6, $6, 1
		addiu $6, $6, 0x60000000
		
		move_two_bytes:
			jal wait_for_flash_read
			lw $1, 0($6)
			sb $1, 0($2)
			srl $1, $1, 8
			sb $1, 1($2)
			addiu $2, $2, 2
			addiu $6, $6, 2
			bne $2, $3, move_two_bytes
			
	/* Back to the beginning */
  j load_address

	write_to_flash:
    /* Write to Flash, 4K each time */
    addiu $3, $2, 4096
		
		write_two_bytes_flash:
      jal wait_for_read
      lbu $1, 0($10)
			addiu $6, $1, 0
			sll $6 ,$6, 8
      jal wait_for_read
      lbu $1, 0($10)
			addu $1, $1, $6
			addu $6, $2, 0xA0000000
			jal wait_for_flash_write
			sw $1, 0($6)
			addiu $2, $2, 2
			bne $2, $3, write_two_bytes_flash
			
	/* Back to the beginning */
  j load_address
		
	
	
	
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
	
	wait_for_flash_read:
		li $16, 0xBE000000
		addiu $16, $16, 0x60000000
    not_ready_for_flash_read:
      lw $17, 0($16)
    bgez $17, not_ready_for_flash_read
    jr ra
	
	wait_for_flash_write:
		li $16, 0xBE000000
		addiu $16, $16, 0xA0000000
    not_ready_for_flash_write:
      lw $17, 0($16)
    bgez $17, not_ready_for_flash_write
    jr ra

  jump_to_os_entry:
    jal wait_for_read
    lbu $1, 0($10)
    li $1, 0x80000000
    jr $1

END(_start)

/* be000000 */
