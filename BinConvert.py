import argparse
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
    
def createRAMImage(binaryFile, maxInstructionCount, ramSize, ramImageFile):
    for i in range(0, maxInstructionCount):
        instructionStr = f.read(4)
        instruction = 0
        for j in range(0, 4):
            instruction += (instructionStr[j] << (j * 8))
        ramImageFile.write(writeRAMWord(instruction) + "\n")
    for i in range(0, ramSize - maxInstructionCount):
        ramImageFile.write(writeRAMWord(0) + "\n")

f = open("MIPSBarebone/barebone.bin", "rb")
fout = open("/mnt/tmpfs/RAM.txt", "w")
createRAMImage(f,100,1024,fout)
fout.close()
f.close()

print(writeRAMWord(12))