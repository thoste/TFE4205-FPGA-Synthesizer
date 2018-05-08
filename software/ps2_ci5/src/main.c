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
 * get_key() reads from PS2 input (by polling) until a valid input is received.
 * This function blocks until it receives valid input.
 * NOTE: Polling is bad. Interrupts is God.
 */
unsigned get_key();

/*
 * valid_key() checks if the argument appears to be a valid key. It returns 0
 * if not valid.
 */
int valid_key(unsigned key);

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
 * handle_key() analyzes the key and passes the appropriate information on to
 * update_synth_tones().
 */
void handle_key(unsigned key);

int
main()
{
        unsigned key;

        while ( 1 ) {
                key = get_key();
                printf("Key: %x\n", key);
                handle_key(key);
        }
        return 0;
}

/*******************************************************************************
 *
 * My little helpers
 *
 ******************************************************************************/

int
valid_key(unsigned key)
{
        unsigned lsb;

        lsb = key & 0xff;
        return lsb != 0;
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
        unsigned key, tmp, prev;

        key = tmp = prev = 0;
        while ( 1 ) {
                tmp = ALT_CI_KEYBOARD_CI_0;
                if ( tmp && tmp != prev ) {
                        if ( tmp == 0xf0 || tmp == 0xe0 ) {
                                key <<= 8;
                                key |= tmp << 8;
                        } else {
                                key |= tmp;
                        }
                }
                if ( !tmp && valid_key(key) )
                        break;
                if ( tmp )
                        prev = tmp;

        }
        return key;
}

void
update_synth_tones(int rel_tone, int opcode, int oct_key)
{
        static int tones_status[NUM_REL_TONES];
        static int prev_octave = 4;
        int        octave, abs_tone;

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
                                ALT_CI_SYNTH_CI_0(key_off, abs_tone, 0);
                prev_octave = octave;

                for ( int i = 0; i < NUM_REL_TONES; i++ )
                        if ( (abs_tone = rel_to_abs_tone(i, octave)) != -1 ) {
                                if ( tones_status[i] )
                                        ALT_CI_SYNTH_CI_0(key_on, abs_tone, 0);
                                else
                                        ALT_CI_SYNTH_CI_0(key_off, abs_tone, 0);
                        }
        } else {
                if ( (abs_tone = rel_to_abs_tone(rel_tone, octave)) != -1 ) {
                        if ( opcode == key_on )
                                ALT_CI_SYNTH_CI_0(key_on, abs_tone, 0);
                        else
                                ALT_CI_SYNTH_CI_0(key_off, abs_tone, 0);
                }
        }
}

void
handle_key(unsigned key)
{
        int opcode, rel_tone, byte1, byte2;

        byte1   = key & 0xff;
        byte2   = (key >> 8) & 0xff;
        opcode  = (byte2 == 0xf0) ?  key_off : key_on;
        rel_tone = key_to_rel_tone(byte1);

        update_synth_tones(rel_tone, opcode, key);
}
