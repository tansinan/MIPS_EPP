import argparse
import os
import serial
import time
import sys
from subprocess import call
#argumentParser = argparse.ArgumentParser(description = 'MIPS_EPP on-chip bootloader utility')

#argumentParser.parse_args();

def sendFileBySerial(serialObject, binaryFile):
    def integerToLittleEndianArray(value):
        ret = []
        for i in range(0, 4):
            ret.append(value % 256)
            value //= 256
        return ret

    def littleEndianArrayToInteger(arr):
        ret = 0
        for i in range(0, 4):
            ret += (arr[i] << (i * 8))
        return ret

    CHUNK_SIZE = 4096
    binaryFile.seek(0)
    address = 0x80000000
    while True:
        fileData = binaryFile.read(CHUNK_SIZE)
        actualLength = len(fileData)
        if actualLength == 0:
            break

        addressArr = integerToLittleEndianArray(address)
        serialObject.write(addressArr)
        print(addressArr)

        dataArr = []
        checksum = 0
        for byte in fileData:
            dataArr.append(byte)
            checksum += byte
        if actualLength < CHUNK_SIZE:
            for i in range(actualLength, CHUNK_SIZE):
                dataArr.append(0)
        print(len(dataArr))
        serialObject.write(dataArr)
        receivedChecksumArr = serialObject.read(4)
        print(len(receivedChecksumArr))
        receivedChecksum = littleEndianArrayToInteger(receivedChecksumArr)
        print('Expected checksum : %x' % checksum)
        print('Received checksum : %x' % receivedChecksum)
        print('0x%x: %d bytes padding to %d bytes, checksum: %d' %
              (address, actualLength, len(dataArr), checksum))
        if actualLength < CHUNK_SIZE:
            break
        address += CHUNK_SIZE
        print('............')
    print('Done.')

inputFile = open(sys.argv[1], "rb")
serialObject = serial.Serial('/dev/ttyUSB0', 115200, timeout=10)
sendFileBySerial(serialObject, inputFile)
serialObject.write([0, 0, 0, 0])
