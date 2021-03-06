# A brief explanation.
#  
# Copyright (C) 2001 MontaVista Software Inc.
# Author: Jun Sun, jsun@mvista.com or jsun@junsun.net
# 
# This program is free software; you can redistribute  it and/or modify it
# under  the terms of  the GNU General  Public License as published by the
# Free Software Foundation;  either version 2 of the  License, or (at your
# option) any later version.

######## CONFIGURATION #########

LOADADDR = 0x80000000
RAMSIZE = 0x00100000		# 1MB

CROSS_COMPILE = mipsel-linux-gnu-

######## END OF CONFIGURATION #########

.S.s:
	$(CPP) $(CFLAGS) $< -o $*.s
.S.o:
	$(CC) $(CFLAGS) -c $< -o $*.o
.c.o:
	$(CC) $(CFLAGS) -c $< -o $*.o

CC =       $(CROSS_COMPILE)gcc
LD =       $(CROSS_COMPILE)ld
OBJCOPY =  $(CROSS_COMPILE)objcopy
OBJDUMP =  $(CROSS_COMPILE)objdump

CFLAGS = -O -G 0 -mno-abicalls -fno-delayed-branch -fno-pic -Wall -DRAMSIZE=${RAMSIZE}

# Drop some uninteresting sections in the kernel.
# This is only relevant for ELF kernels but doesn't hurt a.out
drop-sections   = .reginfo .mdebug
strip-flags     = $(addprefix --remove-section=,$(drop-sections))


all : elf bin

elf : bootloader.elf
bin : bootloader.bin

bootloader.elf : bootloader.o
	$(LD) -o bootloader.elf -N -Tbootloader.lds -Ttext $(LOADADDR) $^

bootloader.bin : bootloader.elf
	$(OBJCOPY) -S -O binary $(strip-flags) bootloader.elf bootloader.bin

clean:
	rm -f *.o bootloader.elf bootloader.bin
