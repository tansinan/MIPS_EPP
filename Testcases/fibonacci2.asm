/*
In this test case, the following instructions are tested:
ADDIU, LW, SW, ADDU, J, BEQ, SLT, SLTI, ANDI, ORI, SUBU,
LUI(from pseduo instruction LI)
*/
addiu $1, $0, 1
addiu $2, $0, 1
addiu $3, $0, 0
addiu $4, $0, 10
li $10, 0xa0000000
ori $10, $10, 128

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

slt $5, $3, $4
li $6, 0xF0
ori $6, 1
andi $6, 1
slti $7, $3, 10
addu $7, $7, $5
subu $7, $7, $6
beq $7, $6, myfibloop
addiu $0, $0, 0

lw $1, 0($10)
lw $2, 4($10)

halt:
j halt
addiu $0, $0, 0
addiu $0, $0, 0