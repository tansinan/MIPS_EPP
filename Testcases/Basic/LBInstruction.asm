/*
In this test case, the following instructions are tested:
LUI, ORI, SW, LH, LB, LHU, LBU, J
*/
    li $10, 0x80000000
    ori $10, $10, 128

    li $1, 0xd591af37

    sw $1, 0($10)

    lh $2, 0($10)
    lb $3, 1($10)
    lh $4, 2($10)
    lb $5, 3($10)
    lhu $6, 0($10)
    lbu $7, 1($10)
    lhu $8, 2($10)
    lbu $9, 3($10)
halt:
    j halt
    nop