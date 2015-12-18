import argparse
import os
import serial
from subprocess import call
argumentParser = argparse.ArgumentParser(description = 'MIPS_EPP on-chip bootloader utility')

argumentParser.parse_args();
    
def sendFileBySerial(serialObject, binaryFile):
    CHUNK_SIZE = 128
    binaryFile.seek(0)
    address = 0x80000000
    while True:
        addressArr = []
        tempAddress = address
        for i in range(0, 4):
            addressArr.append(tempAddress % 256)
        serialObject.write(addressArr)
        print(addressArr)
        fileData = binaryFile.read(CHUNK_SIZE)
        actualLength = len(fileData)
        if actualLength == 0:
            break
        dataArr = []
        checksum = 0
        for byte in fileData:
            dataArr.append(byte)
            checksum += byte
        if actualLength < CHUNK_SIZE:
            for i in range(actualLength, CHUNK_SIZE):
                dataArr.append(i)
        serialObject.write(dataArr)
        checksum %= 256
        receivedChecksum = serialObject.read(1)
        # TODO :Add checksum comparing.
        print('0x%x: %d bytes padding to %d bytes, checksum: %d' %
              (address, actualLength, len(dataArr), checksum))
        if actualLength < CHUNK_SIZE:
            break
        address += CHUNK_SIZE
    print('Done.')

inputFile = open("bootloader.bin", "rb")
serialObject = serial.Serial('/dev/tty1', 115200, timeout=1)
sendFileBySerial(serialObject, inputFile)
