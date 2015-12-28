import argparse
import os
import sys
from subprocess import call

def writeRAMWord(val):
    ret = "";
    for i in range(0, 32):
        if (val & (1 << (31 - i))) != 0:
            ret += "1"
        else:
            ret += "0"
    return ret;
    
def createRAMImage(binaryFile, maxInstructionCount, ramSize, ramImageFile):
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

f = open(sys.argv[1], "rb")

fout = open("/mnt/MIPS_EPP_RAMDISK/RAM1.txt", "w")
createRAMImage(f,5000,1024 * 16,fout)
fout.close()

fout = open("/mnt/MIPS_EPP_RAMDISK/RAM2.txt", "w")
createRAMImage(f,5000,1024 * 16,fout)
fout.close()

f.close()
