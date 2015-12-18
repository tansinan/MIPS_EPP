	li $10, 0xb40003f8
	li $11, 'H'
	sw $11, 0($10)
	jal wait_for_serial
	nop
        li $10, 0xb40003f8
	li $11, 'e'
	sw $11, 0($10)
halt:
j halt
nop

wait_for_serial:
li $2, 0xb400040C
lw $1, 0($2)
andi $1, $1, 0x20
beqz $1, wait_for_serial
nop
jr ra
	nop
	nop
	nop