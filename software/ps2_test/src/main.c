#include <stdio.h>
#include "system.h"
#include "altera_avalon_pio_regs.h"

int
main()
{
        unsigned keys;

        while ( 1 ) {
                keys = IORD_ALTERA_AVALON_PIO_DATA(PIO_KEYBOARD_BASE);
                printf("Keys: %x\n", keys);

                for ( int cnt = 0; cnt < 2000000; cnt++ )
                        ;
        }

        return 0;
}
