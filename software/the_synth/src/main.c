#include <stdio.h>
#include "system.h"
#include "altera_avalon_pio_regs.h"
#include "mappings.h"

/*
 * Opcodes for the synth custom instruction
 */
enum OPCODE {
        key_on,
        key_off,
        effect_on,
        effect_off,
};

/*
 * led_on() and led_off() controlls the leds on the dev board. num is the number
 * of one of the leds, range 0 - 17.
 */
void led_on(int num);
void led_off(int num);

/*
 * set_leds() controls the dev boards leds by writing val to the leds.
 */
void set_leds(unsigned val);

/*
 * key_to_rel_tone() takes a key and returns the note offset from an A i.e.:
 * 0 - A, 1 - Bb, 2 - B, etc.
 * The key values are defined by the PS2 protocol.
 * Returns -1 if the key doesn't corespond to a note.
 */
int key_to_rel_tone(unsigned key);

/*
 * rel_to_abs_tone() returns which of the 88 keyboard tones the relative tone
 * coresponds to in the given octave.
 * Returns -1 if the tone doesn't exist.
 */
int rel_to_abs_tone(int rel_tone, int octave);

/*
 * update_synth_tones() tells synth which tones to play and handles logistics
 * with relative tones and octaves.
 */
void update_synth_tones(int rel_tone, int opcode, int oct_key);

/*
 * get_key() reads from PS2 input (by polling) until a valid input is received.
 * This function blocks until it receives valid input.
 * NOTE: Polling is bad. Interrupts is God.
 */
unsigned get_key();

/*
 * handle_key() analyzes the key and passes the appropriate information on to
 * update_synth_tones().
 */
void handle_key(unsigned key);

/*
 * get_switches() returns current status of the switches. Does not block.
 */
unsigned get_switches();

/*
 * handle_switches() tells the synth which effects to use according to the
 * the status of the switches.
 */
void handle_switches(unsigned sw) ;

int
main()
{
        unsigned key, sw;

        while ( 1 ) {
                sw = get_switches();
                handle_switches(sw);
                key = get_key();
                handle_key(key);
        }
        return 0;
}

/*******************************************************************************
 *
 * My little helpers
 *
 ******************************************************************************/

void
led_on(int num)
{
        unsigned tmp;

        if ( num < 0 || num > 17 )
                return;

        tmp = IORD_ALTERA_AVALON_PIO_DATA(PIO_LED_BASE);
        IOWR_ALTERA_AVALON_PIO_DATA(PIO_LED_BASE, tmp | (1 << num));
}

void
led_off(int num)
{
        unsigned tmp, mask;

        if ( num < 0 || num > 17 )
                return;

        mask = ~0 ^ (1 << num);
        tmp = IORD_ALTERA_AVALON_PIO_DATA(PIO_LED_BASE);
        IOWR_ALTERA_AVALON_PIO_DATA(PIO_LED_BASE, tmp & mask);
}

void
set_leds(unsigned val)
{
        IOWR_ALTERA_AVALON_PIO_DATA(PIO_LED_BASE, val & 0x3ffff);
}

int
key_to_rel_tone(unsigned key)
{
        int res;

        switch ( key ) {
        case A:
                res = 0;
                break;
        case W:
                res = 1;
                break;
        case S:
                res = 2;
                break;
        case D:
                res = 3;
                break;
        case R:
                res = 4;
                break;
        case F:
                res = 5;
                break;
        case T:
                res = 6;
                break;
        case G:
                res = 7;
                break;
        case H:
                res = 8;
                break;
        case U:
                res = 9;
                break;
        case J:
                res = 10;
                break;
        case I:
                res = 11;
                break;
        case K:
                res = 12;
                break;
        case O:
                res = 13;
                break;
        case L:
                res = 14;
                break;
        case OE:
                res = 15;
                break;
        case AA:
                res = 16;
                break;
        case AE:
                res = 17;
                break;
        default:
                res = -1;
        }
        return res;
}

int
rel_to_abs_tone(int rel_tone, int octave)
{
        int tone;

        if ( rel_tone < 0 || rel_tone >= NUM_REL_TONES )
                return -1;

        tone = rel_tone + 12 * octave;
        return (tone < 88) ? tone : -1;
}

unsigned
get_key()
{
        unsigned key;

        while ( !(key = ALT_CI_KEYBOARD_CI_0) )
                ;
        printf("key: %x\n", key);
        return key;
}

void
update_synth_tones(int rel_tone, int opcode, int oct_key)
{
        static int tones_status[NUM_REL_TONES];
        static int prev_octave = 4;
        int        octave, abs_tone, leds;

        octave = prev_octave;
        if ( oct_key == LT )
                octave--;
        else if ( oct_key == Z )
                octave++;

        if ( rel_tone != -1 )
                tones_status[rel_tone] = (opcode == key_on) ? 1 : 0;

        if ( octave != prev_octave ) {
                for ( int i = 0; i < NUM_REL_TONES; i++ )
                        if ( (abs_tone = rel_to_abs_tone(i, prev_octave)) != -1 )
                                ALT_CI_SYNTH_CI_0(key_off, abs_tone);

                prev_octave = octave;
                leds        = 0;
                for ( int i = 0; i < NUM_REL_TONES; i++ )
                        if ( (abs_tone = rel_to_abs_tone(i, octave)) != -1 ) {
                                if ( tones_status[i] ) {
                                        ALT_CI_SYNTH_CI_0(key_on, abs_tone);
                                        leds |= (1 << i);
                                } else {
                                        ALT_CI_SYNTH_CI_0(key_off, abs_tone);
                                }
                        }
                set_leds(leds);
        } else {
                if ( (abs_tone = rel_to_abs_tone(rel_tone, octave)) != -1 ) {
                        if ( opcode == key_on ) {
                                ALT_CI_SYNTH_CI_0(key_on, abs_tone);
                                led_on(rel_tone);
                        } else {
                                ALT_CI_SYNTH_CI_0(key_off, abs_tone);
                                led_off(rel_tone);
                        }
                }
        }
}

void
handle_key(unsigned key)
{
        int opcode, rel_tone, byte1, byte2;

        byte1    = key & 0xff;
        byte2    = (key >> 8) & 0xff;
        opcode   = (byte2 == 0xf0) ?  key_off : key_on;
        rel_tone = key_to_rel_tone(byte1);

        update_synth_tones(rel_tone, opcode, key);
}

unsigned
get_switches()
{
        return IORD_ALTERA_AVALON_PIO_DATA(PIO_SWITCHES_BASE);
}

void
handle_switches(unsigned sw)
{
        static unsigned prev_sw = 0;

        if ( sw != prev_sw )
                prev_sw = sw;
        else
                return;

        if ( sw & 0x1 )
                ALT_CI_SYNTH_CI_0(effect_on, 0);
        else
                ALT_CI_SYNTH_CI_0(effect_off, 0);

        if ( sw & 0x2 )
                ALT_CI_SYNTH_CI_0(effect_on, 1);
        else
                ALT_CI_SYNTH_CI_0(effect_off, 1);
}
