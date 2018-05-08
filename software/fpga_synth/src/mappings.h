#ifndef MAPPINGS_H_
#define MAPPINGS_H_

enum TONES {
        C8 , B7 , Bb7, A7 , Ab7, G7 , Gb7, F7 , E7 , Eb7, D7 , Db7, C7 , B6 ,
        Bb6, A6 , Ab6, G6 , Gb6, F6 , E6 , Eb6, D6 , Db6, C6 , B5 , Bb5, A5 ,
        Ab5, G5 , Gb5, F5 , E5 , Eb5, D5 , Db5, C5 , B4 , Bb4, A4 , Ab4, G4 ,
        Gb4, F4 , E4 , Eb4, D4 , Db4, C4 , B3 , Bb3, A3 , Ab3, G3 , Gb3, F3 ,
        E3 , Eb3, D3 , Db3, C3 , B2 , Bb2, A2 , Ab2, G2 , Gb2, F2 , E2 , Eb2,
        D2 , Db2, C2 , B1 , Bb1, A1 , Ab1, G1 , Gb1, F1 , E1 , Eb1, D1 , Db1,
        C1 , B0 , Bb0, A0,
};

/*
 * Keyboard values of used keys
 */
#define A 0x1c  /* A  */
#define W 0x1d  /* Bb */
#define S 0x1b  /* B  */
#define D 0x23  /* C  */
#define R 0x2d  /* C# */
#define F 0x2b  /* D  */
#define T 0x2c  /* Eb */
#define G 0x34  /* E  */
#define H 0x33  /* F  */
#define U 0x3c  /* F# */
#define J 0x3b  /* G  */
#define I 0x43  /* G# */
#define K 0x42  /* A  */
#define O 0x44  /* Bb */
#define L 0x4b  /* B  */
#define OE 0x4c /* C  */
#define AA 0x54 /* C# */
#define AE 0x52 /* D  */

#define LT 0x61 /* Octave down */
#define Z 0x1a  /* Octave up */

/*
 * Number of relative tones is the number of tones it is possible to play at
 * the same time. It equals the number keys used to play.
 */
#define NUM_REL_TONES 18

#endif /* MAPPINGS_H_ */
