// ============================================================================
// Copyright (c) 2012 by Terasic Technologies Inc.
// ============================================================================
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development
//   Kits made by Terasic.  Other use of this code, including the selling
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use
//   or functionality of this code.
//
// ============================================================================
//
//  Terasic Technologies Inc
//  9F., No.176, Sec.2, Gongdao 5th Rd, East Dist, Hsinchu City, 30070. Taiwan
//
//
//
//                     web: http://www.terasic.com/
//                     email: support@terasic.com
//
// ============================================================================
//
// Major Functions:    DE2_115_Default
//
// ============================================================================
//
// Revision History :
// ============================================================================
//   Ver  :| Author              :| Mod. Date :| Changes Made:
//   V1.1 :| HdHuang             :| 05/12/10  :| Initial Revision
//   V2.0 :| Eko                       :| 05/23/12  :| version 11.1
// ============================================================================

module DE2_115_Synthesizer(
    /*
     * CLOCK_50 is the main clock for the module
     * ENETCLK_25 cannot be removed, BUT WHAT DOES IT DO ?!
     */
    input CLOCK_50,
    input ENETCLK_25,

    /*
     * LEDG - LEDs over the four buttons
     * LEDR - LEDs over the switches
     */
    output [7:0]  LEDG,
    output [17:0] LEDR,

    /*
     * Board switches
     */
    input [17:0] SW,

    /*
     * KEY - Input from the four buttons
     */
    input [3:0] KEY,

    /*
     * Output to the eight seven-segment displays
     */
    output [6:0] HEX0,
    output [6:0] HEX1,
    output [6:0] HEX2,
    output [6:0] HEX3,
    output [6:0] HEX4,
    output [6:0] HEX5,
    output [6:0] HEX6,
    output [6:0] HEX7,

    /*
     * LCD screen interface
     */
    inout  [7:0] LCD_DATA,
    output       LCD_BLON,
    output       LCD_EN,
    output       LCD_ON,
    output       LCD_RS,
    output       LCD_RW,


    /*
     * Keyboard interface
     */
    inout PS2_CLK,
    inout PS2_DAT,
    inout PS2_CLK2,
    inout PS2_DAT2,

    /*
     * Audio interface to/from DAC/ADC
     */
    input  AUD_ADCDAT,
    inout  AUD_ADCLRCK,
    inout  AUD_BCLK,
    output AUD_DACDAT,
    inout  AUD_DACLRCK,
    output AUD_XCK,

    /*
     * I2C for Audio and Tv-Decode
     */
    output I2C_SCLK,
    inout  I2C_SDAT,

    /*
     * TV decoder interface. Cannot be removed (?) because:
     * TD_CLK27 - Used in VGA_Audio_PLL.
     * TD_RESET_N - Used to enable the decoder (which has to be enabled?)
     */
    input  TD_CLK27,
    output TD_RESET_N,

    /*
     * CPU interface
     */
    input [87:0] sound_in,
    input [17:0] effects_ctrl
);

    /***************************************************************************
     *
     * Frequencies
     *
     **************************************************************************/

    wire [15:0] C8 ;
    wire [15:0] B7 ;
    wire [15:0] Bb7;
    wire [15:0] A7 ;
    wire [15:0] Ab7;
    wire [15:0] G7 ;
    wire [15:0] Gb7;
    wire [15:0] F7 ;
    wire [15:0] E7 ;
    wire [15:0] Eb7;
    wire [15:0] D7 ;
    wire [15:0] Db7;
    wire [15:0] C7 ;
    wire [15:0] B6 ;
    wire [15:0] Bb6;
    wire [15:0] A6 ;
    wire [15:0] Ab6;
    wire [15:0] G6 ;
    wire [15:0] Gb6;
    wire [15:0] F6 ;
    wire [15:0] E6 ;
    wire [15:0] Eb6;
    wire [15:0] D6 ;
    wire [15:0] Db6;
    wire [15:0] C6 ;
    wire [15:0] B5 ;
    wire [15:0] Bb5;
    wire [15:0] A5 ;
    wire [15:0] Ab5;
    wire [15:0] G5 ;
    wire [15:0] Gb5;
    wire [15:0] F5 ;
    wire [15:0] E5 ;
    wire [15:0] Eb5;
    wire [15:0] D5 ;
    wire [15:0] Db5;
    wire [15:0] C5 ;
    wire [15:0] B4 ;
    wire [15:0] Bb4;
    wire [15:0] A4 ;
    wire [15:0] Ab4;
    wire [15:0] G4 ;
    wire [15:0] Gb4;
    wire [15:0] F4 ;
    wire [15:0] E4 ;
    wire [15:0] Eb4;
    wire [15:0] D4 ;
    wire [15:0] Db4;
    wire [15:0] C4 ;
    wire [15:0] B3 ;
    wire [15:0] Bb3;
    wire [15:0] A3 ;
    wire [15:0] Ab3;
    wire [15:0] G3 ;
    wire [15:0] Gb3;
    wire [15:0] F3 ;
    wire [15:0] E3 ;
    wire [15:0] Eb3;
    wire [15:0] D3 ;
    wire [15:0] Db3;
    wire [15:0] C3 ;
    wire [15:0] B2 ;
    wire [15:0] Bb2;
    wire [15:0] A2 ;
    wire [15:0] Ab2;
    wire [15:0] G2 ;
    wire [15:0] Gb2;
    wire [15:0] F2 ;
    wire [15:0] E2 ;
    wire [15:0] Eb2;
    wire [15:0] D2 ;
    wire [15:0] Db2;
    wire [15:0] C2 ;
    wire [15:0] B1 ;
    wire [15:0] Bb1;
    wire [15:0] A1 ;
    wire [15:0] Ab1;
    wire [15:0] G1 ;
    wire [15:0] Gb1;
    wire [15:0] F1 ;
    wire [15:0] E1 ;
    wire [15:0] Eb1;
    wire [15:0] D1 ;
    wire [15:0] Db1;
    wire [15:0] C1 ;
    wire [15:0] B0 ;
    wire [15:0] Bb0;
    wire [15:0] A0 ;

    assign C8  = 4186;
    assign B7  = 3951;
    assign Bb7 = 3729;
    assign A7  = 3520;
    assign Ab7 = 3322;
    assign G7  = 3135;
    assign Gb7 = 2959;
    assign F7  = 2793;
    assign E7  = 2637;
    assign Eb7 = 2489;
    assign D7  = 2349;
    assign Db7 = 2217;
    assign C7  = 2093;
    assign B6  = 1975;
    assign Bb6 = 1864;
    assign A6  = 1760;
    assign Ab6 = 1661;
    assign G6  = 1567;
    assign Gb6 = 1479;
    assign F6  = 1396;
    assign E6  = 1318;
    assign Eb6 = 1244;
    assign D6  = 1174;
    assign Db6 = 1108;
    assign C6  = 1046;
    assign B5  = 987;
    assign Bb5 = 932;
    assign A5  = 880;
    assign Ab5 = 830;
    assign G5  = 783;
    assign Gb5 = 739;
    assign F5  = 698;
    assign E5  = 659;
    assign Eb5 = 622;
    assign D5  = 587;
    assign Db5 = 554;
    assign C5  = 523;
    assign B4  = 493;
    assign Bb4 = 466;
    assign A4  = 440;
    assign Ab4 = 415;
    assign G4  = 391;
    assign Gb4 = 369;
    assign F4  = 349;
    assign E4  = 329;
    assign Eb4 = 311;
    assign D4  = 293;
    assign Db4 = 277;
    assign C4  = 261;
    assign B3  = 246;
    assign Bb3 = 233;
    assign A3  = 220;
    assign Ab3 = 207;
    assign G3  = 195;
    assign Gb3 = 184;
    assign F3  = 174;
    assign E3  = 164;
    assign Eb3 = 155;
    assign D3  = 146;
    assign Db3 = 138;
    assign C3  = 130;
    assign B2  = 123;
    assign Bb2 = 116;
    assign A2  = 110;
    assign Ab2 = 103;
    assign G2  = 97;
    assign Gb2 = 92;
    assign F2  = 87;
    assign E2  = 82;
    assign Eb2 = 77;
    assign D2  = 73;
    assign Db2 = 69;
    assign C2  = 65;
    assign B1  = 61;
    assign Bb1 = 58;
    assign A1  = 55;
    assign Ab1 = 51;
    assign G1  = 48;
    assign Gb1 = 46;
    assign F1  = 43;
    assign E1  = 41;
    assign Eb1 = 38;
    assign D1  = 36;
    assign Db1 = 34;
    assign C1  = 32;
    assign B0  = 30;
    assign Bb0 = 29;
    assign A0  = 27;

    /***************************************************************************
     *
     * SIGNAL declarations
     *
     **************************************************************************/
    wire        I2C_END;
    wire        AUD_CTRL_CLK;
    reg  [31:0] VGA_CLKo;
    wire        keyboard_sysclk;
    wire  [7:0] scan_code;
    wire        get_gate;
    wire        key1_on;
    wire        key2_on;
    wire  [7:0] key1_code;
    wire  [7:0] key2_code;

    /***************************************************************************
     *
     * Structural coding
     *
     **************************************************************************/

    always @ ( posedge CLOCK_50 ) begin
        VGA_CLKo <= VGA_CLKo + 1;
    end

    /*
     * Keyboard setup
     */
    assign keyboard_sysclk = VGA_CLKo[12]; // keyboard_sysclk = CLOCK_50 / 2^12
    assign PS2_DAT2        = 1'b1;
    assign PS2_CLK2        = 1'b1;

    // KeyBoard Scan
    ps2_keyboard keyboard (
        .iCLK_50   ( CLOCK_50),          //clock source;
        .ps2_dat   ( PS2_DAT ),          //ps2bus data
        .ps2_clk   ( PS2_CLK ),          //ps2bus clk
        .sys_clk   ( keyboard_sysclk ),  //system clock
        .reset     ( KEY[3] ),           //system reset
        .reset1    ( KEY[2] ),           //keyboard reset
        .scandata  ( scan_code ),        //scan code
        .key1_on   ( key1_on ),          //key1 triger
        .key2_on   ( key2_on ),          //key2 triger
        .key1_code ( key1_code ),        //key1 code
        .key2_code ( key2_code )         //key2 code
    );

    /*
     * TV decoder enable
     */
    assign TD_RESET_N =1'b1;

    /*
     * 7-Seg component
     */
    SEG7_LUT_8 u0 (
        HEX0,
        HEX1,
        HEX2,
        HEX3,
        HEX4,
        HEX5,
        HEX6,
        HEX7,
        31'h00001112
    );

    /*
     * I2C bus component.
     * Cannot delete it (?) because it controls the I2C_END signal.
     */
    I2C_AV_Config u7 (
        // Host Side
        .iCLK      ( CLOCK_50 ),
        .iRST_N    ( TD_RESET_N ),
        .o_I2C_END ( I2C_END ),
        // I2C Side
        .I2C_SCLK ( I2C_SCLK ),
        .I2C_SDAT ( I2C_SDAT )
    );


    /*
     * Audio setup.
     */
    assign AUD_ADCLRCK = AUD_DACLRCK;
    assign AUD_XCK     = AUD_CTRL_CLK;

    VGA_Audio_PLL u1 (
        .areset ( ~I2C_END ),
        .inclk0 ( TD_CLK27 ),
        .c1     ( AUD_CTRL_CLK )
    );

    /*
     * LED display
     */
    assign LEDR[9:6] = { sound_in[3], sound_in[2], sound_in[1], sound_in[0] };
    assign LEDG[7:0] = scan_code;

    /*
     * 2CH Audio Sound output -- Audio Generater
     */
    adio_codec ad1 (
        // AUDIO CODEC
        .oAUD_BCK  ( AUD_BCLK ),
        .oAUD_DATA ( AUD_DACDAT ),
        .oAUD_LRCK ( AUD_DACLRCK ),
        .iCLK_18_4 ( AUD_CTRL_CLK ),
        // KEY
        .iRST_N      ( TD_RESET_N ),
        .iSrc_Select ( 2'b00 ),
        // Sound Control
        .key1_on ( ~SW[1] & sound_in[0] ), //CH1 ON / OFF
        .key2_on ( ~SW[2] & sound_in[1] ), //CH2 ON / OFF
        .key3_on ( ~SW[3] & sound_in[2] ), //CH3 ON / OFF
        .key4_on ( ~SW[4] & sound_in[3] ), //CH4 ON / OFF
        .sound1  ( A4 ), // CH1 Freq
        .sound2  ( Db5 ), // CH2 Freq
        .sound3  ( E5 ), // OFF,CH3 Freq
        .sound4  ( A5 ), // OFF,CH4 Freq
        .instru  ( SW[0] )   // Instruction Select
    );


    /*
     * LCD setup
     */
    assign LCD_ON   = 1'b1;
    assign LCD_BLON = 1'b1;

    LCD_TEST u5 (
        // Host Side
        .iCLK   ( CLOCK_50 ),
        .iRST_N ( TD_RESET_N & I2C_END ),
        // LCD Side
        .LCD_DATA ( LCD_DATA ),
        .LCD_RW   ( LCD_RW ),
        .LCD_EN   ( LCD_EN ),
        .LCD_RS   ( LCD_RS )
    );
endmodule

/* Frequences with decimal:
    wire [15:0] C8  = 4186.01;
    wire [15:0] B7  = 3951.07;
    wire [15:0] Bb7 = 3729.31;
    wire [15:0] A7  = 3520.00;
    wire [15:0] Ab7 = 3322.44;
    wire [15:0] G7  = 3135.96;
    wire [15:0] Gb7 = 2959.96;
    wire [15:0] F7  = 2793.83;
    wire [15:0] E7  = 2637.02;
    wire [15:0] Eb7 = 2489.02;
    wire [15:0] D7  = 2349.32;
    wire [15:0] Db7 = 2217.46;
    wire [15:0] C7  = 2093.00;
    wire [15:0] B6  = 1975.53;
    wire [15:0] Bb6 = 1864.66;
    wire [15:0] A6  = 1760.00;
    wire [15:0] Ab6 = 1661.22;
    wire [15:0] G6  = 1567.98;
    wire [15:0] Gb6 = 1479.98;
    wire [15:0] F6  = 1396.91;
    wire [15:0] E6  = 1318.51;
    wire [15:0] Eb6 = 1244.51;
    wire [15:0] D6  = 1174.66;
    wire [15:0] Db6 = 1108.73;
    wire [15:0] C6  = 1046.50;
    wire [15:0] B5  = 987.767;
    wire [15:0] Bb5 = 932.328;
    wire [15:0] A5  = 880.000;
    wire [15:0] Ab5 = 830.609;
    wire [15:0] G5  = 783.991;
    wire [15:0] Gb5 = 739.989;
    wire [15:0] F5  = 698.456;
    wire [15:0] E5  = 659.255;
    wire [15:0] Eb5 = 622.254;
    wire [15:0] D5  = 587.330;
    wire [15:0] Db5 = 554.365;
    wire [15:0] C5  = 523.251;
    wire [15:0] B4  = 493.883;
    wire [15:0] Bb4 = 466.164;
    wire [15:0] A4  = 440.000;
    wire [15:0] Ab4 = 415.305;
    wire [15:0] G4  = 391.995;
    wire [15:0] Gb4 = 369.994;
    wire [15:0] F4  = 349.228;
    wire [15:0] E4  = 329.628;
    wire [15:0] Eb4 = 311.127;
    wire [15:0] D4  = 293.665;
    wire [15:0] Db4 = 277.183;
    wire [15:0] C4  = 261.626;
    wire [15:0] B3  = 246.942;
    wire [15:0] Bb3 = 233.082;
    wire [15:0] A3  = 220.000;
    wire [15:0] Ab3 = 207.652;
    wire [15:0] G3  = 195.998;
    wire [15:0] Gb3 = 184.997;
    wire [15:0] F3  = 174.614;
    wire [15:0] E3  = 164.814;
    wire [15:0] Eb3 = 155.563;
    wire [15:0] D3  = 146.832;
    wire [15:0] Db3 = 138.591;
    wire [15:0] C3  = 130.813;
    wire [15:0] B2  = 123.471;
    wire [15:0] Bb2 = 116.541;
    wire [15:0] A2  = 110.000;
    wire [15:0] Ab2 = 103.826;
    wire [15:0] G2  = 97.9989;
    wire [15:0] Gb2 = 92.4986;
    wire [15:0] F2  = 87.3071;
    wire [15:0] E2  = 82.4069;
    wire [15:0] Eb2 = 77.7817;
    wire [15:0] D2  = 73.4162;
    wire [15:0] Db2 = 69.2957;
    wire [15:0] C2  = 65.4064;
    wire [15:0] B1  = 61.7354;
    wire [15:0] Bb1 = 58.2705;
    wire [15:0] A1  = 55.0000;
    wire [15:0] Ab1 = 51.9131;
    wire [15:0] G1  = 48.9994;
    wire [15:0] Gb1 = 46.2493;
    wire [15:0] F1  = 43.6535;
    wire [15:0] E1  = 41.2034;
    wire [15:0] Eb1 = 38.8909;
    wire [15:0] D1  = 36.7081;
    wire [15:0] Db1 = 34.6478;
    wire [15:0] C1  = 32.7032;
    wire [15:0] B0  = 30.8677;
    wire [15:0] Bb0 = 29.1352;
    wire [15:0] A0  = 27.5000;
*/
