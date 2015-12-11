import argparse
import os
from subprocess import call
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
    binaryFile.seek(0)
    for i in range(0, maxInstructionCount):
        instructionStr = binaryFile.read(4)
        instruction = 0
        for j in range(0, 4):
            instruction += (instructionStr[j] << (j * 8))
        ramImageFile.write(writeRAMWord(instruction) + "\n")
    for i in range(0, ramSize - maxInstructionCount):
        ramImageFile.write(writeRAMWord(0) + "\n")

#mount -t tmpfs -o size=512M tmpfs /mnt/ramdisk
print("Initializing tmpfs RAM disk on /mnt/MIPS_EPP_RAMDISK...")
if not os.path.isdir("/mnt/MIPS_EPP_RAMDISK"):
    print("/mnt/MIPS_EPP_RAMDISK doesn't exist, creating it.")
    call(["sudo", "rm", "-rf", "/mnt/MIPS_EPP_RAMDISK"])
    call(["sudo", "mkdir", "/mnt/MIPS_EPP_RAMDISK"])
    call(["sudo", "mount", "-t", "tmpfs", "-o", "size=512M", "tmpfs", "/mnt/MIPS_EPP_RAMDISK"])
else:
    print("/mnt/MIPS_EPP_RAMDISK mounted, remounting...")
    call(["sudo", "umount", "/mnt/MIPS_EPP_RAMDISK"])
    call(["sudo", "mount", "-t", "tmpfs", "-o", "size=512M", "tmpfs", "/mnt/MIPS_EPP_RAMDISK"])

f = open("MIPSBarebone/barebone.bin", "rb")

fout = open("/mnt/MIPS_EPP_RAMDISK/RAM1.txt", "w")
createRAMImage(f,200,1024 * 16,fout)
fout.close()

fout = open("/mnt/MIPS_EPP_RAMDISK/RAM2.txt", "w")
createRAMImage(f,200,1024 * 16,fout)
fout.close()

f.close()
