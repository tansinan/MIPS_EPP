/*
In this test case, the following instructions are tested:
ADDIU, LW, SW, ADDU, J, BEQ, SLT, SLTI, ANDI, ORI, SUBU,
LUI, JAL, JR(from pseduo instruction LI)
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
jal add_func
nop
sw $1, 0($10)
sw $2, 4($10)
addiu $1, $0, 0
addiu $2, $0, 0
addiu $3, $3, 1

slt $5, $3, $4
li $6, 0xF0
ori $6, 1
andi $6, 1
slti $30, $3, 10
addu $30, $30, $5
jal sub_func
nop
beq $30, $6, myfibloop
addiu $0, $0, 0

lw $1, 0($10)
lw $2, 4($10)

halt:
j halt
addiu $0, $0, 0
addiu $0, $0, 0

add_func:
addu $1, $1, $2
addu $2, $1, $2
jr $31
nop

sub_func:
subu $30, $30, $6
jr $31
nop