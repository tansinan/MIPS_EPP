/*
 * Copyright (C) 2001 MontaVista Software Inc.
 * Author: Jun Sun, jsun@mvista.com or jsun@junsun.net
 *
 * This program is free software; you can redistribute  it and/or modify it
 * under  the terms of  the GNU General  Public License as published by the
 * Free Software Foundation;  either version 2 of the  License, or (at your
 * option) any later version.
 *
 */

#include "printf.h"

//void printf_test();

main()
{
//for(;;)
{
	printf("\n");
	printf("(main) Hello, world!\n");
	printf("loop forever ...\n");
        printf("Magic:%d\n",12);
    printf("hello through printf!\n");
    printf("test string: %s\n", "test string");
    printf("test int: %d\n", -555);
    printf("test binary: %b\n", 555);
    printf("test hex: %08x\n", 555);
}
	for(;;);
}
