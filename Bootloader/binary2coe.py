import argparse
import os
argumentParser = argparse.ArgumentParser(description = 'MIPS_EPP testing automization utility')

argumentParser.parse_args();

def writeRAMWord(val):
    ret = "";
    for i in range(0, 32):
        if (val & (1 << (31 - i))) != 0:
            ret += "1"
        else:
            ret += "0"
    return ret;
    
def createRAMImage(binaryFile, maxInstructionCount, ramSize, coeFile):
    actualInstructionCount = 0
    binaryFile.seek(0)
    for i in range(0, maxInstructionCount):
        instructionStr = binaryFile.read(4)
        if not instructionStr:
            print(actualInstructionCount)
            break
        actualInstructionCount += 1
        instruction = 0
        for j in range(0, 4):
            instruction += (instructionStr[j] << (j * 8))
        coeFile.write(writeRAMWord(instruction) + ",\n")
    for i in range(0, ramSize - actualInstructionCount):
        if i != ramSize - actualInstructionCount - 1:
            coeFile.write(writeRAMWord(0) + ",\n")
        else:
            coeFile.write(writeRAMWord(0) + ";\n")

f = open("bootloader.bin", "rb")

fout = open("bootloader.coe", "w")
fout.write("MEMORY_INITIALIZATION_RADIX=2;\n");
fout.write("MEMORY_INITIALIZATION_VECTOR=\n");
createRAMImage(f, 128, 128, fout)
fout.close()

f.close()
