/*
 * main.c
 *
 *  Created on: Apr 30, 2018
 *      Author: magnu
 */

#include <stdio.h>
#include "system.h"
#include "altera_avalon_pio_regs.h"

int
main()
{
        printf("Hello from Nios II!\n");

        unsigned val;
        while ( 1 ) {
                val = IORD_ALTERA_AVALON_PIO_DATA(PIO_KEYS_BASE);
                printf("val: %x\n", val);
                for ( int cnt = 0; cnt < 2000000; cnt++ )
                        ;
        }

        return 0;
}
