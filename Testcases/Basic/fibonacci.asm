/*
In this test case, the following instructions are tested:
ADDIU, LW, SW, ADDU, J, BNE
*/
addiu $1, $0, 1
addiu $2, $0, 1
addiu $3, $0, 0
addiu $4, $0, 10
addiu $10, $0, 128
sw $1, 0($10)
sw $2, 4($10)

myfibloop:
lw $1, 0($10)
lw $2, 4($10)
addu $1, $1, $2
addu $2, $1, $2
sw $1, 0($10)
sw $2, 4($10)
addiu $1, $0, 0
addiu $2, $0, 0
addiu $3, $3, 1

bne $3, $4, myfibloop
addiu $0, $0, 0

lw $1, 0($10)
lw $2, 4($10)

halt:
j halt
nop
nop
nop
