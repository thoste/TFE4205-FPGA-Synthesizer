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
    output TD_RESET_N
);

    /***************************************************************************
     *
     * SIGNAL declarations
     *
     **************************************************************************/
    wire        I2C_END;
    wire        AUD_CTRL_CLK;
    reg  [31:0] VGA_CLKo;
    wire        keyboard_sysclk;
    wire        demo_clock;
    wire  [7:0] demo_code1;
    wire  [7:0] demo_code2;
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
        .iRST_N    ( KEY[0] ),
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
     * Music Synthesizer Block
     */
    assign demo_clock = VGA_CLKo[18]; // demo_clock = CLOCK_50 / 2^18

    // Demo sound (Ch1)
    demo_sound1 dd1 (
        .clock   ( demo_clock ),
        .key_code( demo_code1 ),
        .k_tr    ( KEY[1] & KEY[0] )
    );

    // Demo sound (Ch2)
    demo_sound2 dd2 (
        .clock   ( demo_clock ),
        .key_code( demo_code2 ),
        .k_tr    ( KEY[1] & KEY[0] )
    );

    /*
     * Sound select
     */
    wire [15:0] sound1;
    wire [15:0] sound2;
    wire [15:0] sound3;
    wire [15:0] sound4;
    wire        sound_off1;
    wire        sound_off2;
    wire        sound_off3;
    wire        sound_off4;

    wire [7:0] sound_code1 = ( !SW[9] )? demo_code1 : key1_code ; //SW[9]=0 is DEMO SOUND,otherwise key
    wire [7:0] sound_code2 = ( !SW[9] )? demo_code2 : key2_code ; //SW[9]=0 is DEMO SOUND,otherwise key
    wire [7:0] sound_code3 = 8'hf0;
    wire [7:0] sound_code4 = 8'hf0;

    // Staff Sound Output
    staff st1 (
        // Key code-in
        .scan_code1 ( sound_code1 ),
        .scan_code2 ( sound_code2 ),
        .scan_code3 ( sound_code3 ), // OFF
        .scan_code4 ( sound_code4 ), // OFF
        //Sound Output to Audio Generater
        .sound1     ( sound1 ),
        .sound2     ( sound2 ),
        .sound3     ( sound3 ), // OFF
        .sound4     ( sound4 ), // OFF
        .sound_off1 ( sound_off1 ),
        .sound_off2 ( sound_off2 ),
        .sound_off3 ( sound_off3 ), //OFF
        .sound_off4 ( sound_off4 )  //OFF
    );

    /*
     * LED display
     */
    assign LEDR[9:6] = { sound_off4, sound_off3, sound_off2, sound_off1 };
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
        .iRST_N      ( KEY[0] ),
        .iSrc_Select ( 2'b00 ),
        // Sound Control
        .key1_on ( ~SW[1] & sound_off1 ), //CH1 ON / OFF
        .key2_on ( ~SW[2] & sound_off2 ), //CH2 ON / OFF
        .key3_on ( 1'b0 ),   // OFF
        .key4_on ( 1'b0 ),   // OFF
        .sound1  ( sound1 ), // CH1 Freq
        .sound2  ( sound2 ), // CH2 Freq
        .sound3  ( sound3 ), // OFF,CH3 Freq
        .sound4  ( sound4 ), // OFF,CH4 Freq
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
        .iRST_N ( KEY[0] & I2C_END ),
        // LCD Side
        .LCD_DATA ( LCD_DATA ),
        .LCD_RW   ( LCD_RW ),
        .LCD_EN   ( LCD_EN ),
        .LCD_RS   ( LCD_RS )
    );
endmodule
