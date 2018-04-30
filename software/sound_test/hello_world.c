

#include <stdio.h>
#include "system.h"
#include "altera_avalon_pio_regs.h"

int
main()
{
        unsigned keys, note1, note2;

        note1 = 400;
        note2 = 440;
        while ( 1 ) {
                keys = IORD_ALTERA_AVALON_PIO_DATA(PIO_KEYS_BASE);
                if ( !(keys & 0x1) ) {
                        printf("Pressed key1\n");
                        IOWR_ALTERA_AVALON_PIO_DATA(PIO_SOUND_BASE, note1);
                } else if ( !(keys & 0x2) ) {
                        printf("Pressed key2\n");
                        IOWR_ALTERA_AVALON_PIO_DATA(PIO_SOUND_BASE, note2);
                }
                for ( int cnt = 0; cnt < 4000000; cnt++ )
                        ;
        }

        return 0;
}
