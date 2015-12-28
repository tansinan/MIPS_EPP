/*
In this test case, the following instructions are tested:
LUI, ORI, SW, SB, SU, J
*/
    li $10, 0x80000000
    ori $10, $10, 128

    li $1, 0xd591af37

    sw $1, 0($10)
    sw $1, 4($10)

    li $25, 0xfd67a120
    li $26, 0x1398de41
    
    sb $25, 1($10)
    sh $26, 2($10)
    sb $25, 4($10)
    sh $26, 6($10)
    
    lw $25, 0($10)
    lw $26, 4($10)
halt:
    j halt
    nop