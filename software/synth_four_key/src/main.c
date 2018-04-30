#include <stdio.h>
#include "system.h"
#include "altera_avalon_pio_regs.h"

#define sound1 0
#define sound2 1
#define sound3 2
#define sound4 3

enum OPCODE {
        key_on,
        key_off,
        effect_on,
        effect_off,
};

int
main()
{
        unsigned keys;
        unsigned char key1, prev_key1;
        unsigned char key2, prev_key2;
        unsigned char key3, prev_key3;
        unsigned char key4, prev_key4;

        keys = 0;
        while ( 1 ) {
                keys = IORD_ALTERA_AVALON_PIO_DATA(PIO_KEYS_BASE);
                prev_key1 = key1;
                prev_key2 = key2;
                prev_key3 = key3;
                prev_key4 = key4;
                key1      = !(keys & 0x1);
                key2      = !(keys & 0x2);
                key3      = !(keys & 0x4);
                key4      = !(keys & 0x8);


                if ( key1 != prev_key1 ) {
                        printf("Pressed key1\n");
                        if ( key1 )
                                ALT_CI_SYNTH_CI_0(key_on, sound1);
                        else
                                ALT_CI_SYNTH_CI_0(key_off, sound1);
                }

                if ( key2 != prev_key2 ) {
                        printf("Pressed key1\n");
                        if ( key2 )
                                ALT_CI_SYNTH_CI_0(key_on, sound2);
                        else
                                ALT_CI_SYNTH_CI_0(key_off, sound2);
                }

                if ( key3 != prev_key3 ) {
                        printf("Pressed key1\n");
                        if ( key3 )
                                ALT_CI_SYNTH_CI_0(key_on, sound3);
                        else
                                ALT_CI_SYNTH_CI_0(key_off, sound3);
                }

                if ( key4 != prev_key4 ) {
                        printf("Pressed key1\n");
                        if ( key4 )
                                ALT_CI_SYNTH_CI_0(key_on, sound4);
                        else
                                ALT_CI_SYNTH_CI_0(key_off, sound4);
                }

                for ( int cnt = 0; cnt < 100000; cnt++ )
                        ;
        }

        return 0;
}
