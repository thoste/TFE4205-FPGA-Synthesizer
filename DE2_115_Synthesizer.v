module DE2_115_Synthesizer(
    /*
     * CLOCK_50 is the main clock for the module
     * ENETCLK_25 cannot be removed, BUT WHAT DOES IT DO ?!
     */
    input CLOCK_50,
    input ENETCLK_25,

    /*
     * Board switches
     */
    input [17:0] SW,

    /*
     * KEY - Input from the four buttons
     */
    input [3:0] KEY,

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
	
	/*
     * CPU interface
	 * SW 0-3 select sound source; effects_ctrl [3:0].
	 * SW 0 - Sine; SW 1 - Square; 
	 * Disabled during interal testing
     */
	//input [87:0] sound_in,
	//input [17:0] effects_ctrl
	
);

	

    /***************************************************************************
     *
     * SIGNAL declarations
     *
     **************************************************************************/
    wire        I2C_END;
    wire        AUD_CTRL_CLK;
    reg  [31:0] VGA_CLKo;
    wire  [7:0] scan_code;
    wire        get_gate;
	
	
	/*
	 * Testing only; using wire instead of input
     */
	wire [87:0] sound_in;
	assign sound_in[87:12] = 76'b0;
	assign sound_in[11:0] = {SW[17],SW[16],SW[15],SW[14],SW[13],SW[12],SW[11],SW[10],SW[9],SW[8],SW[7],SW[6]};
	
	// SW 0-3 select sound source.  
    wire [17:0] effects_ctrl;
	assign effects_ctrl[3:0] = {SW[3],SW[2],SW[1],SW[0]};

	
    /***************************************************************************
     *
     * Structural coding
     *
     **************************************************************************/

    always @ ( posedge CLOCK_50 ) begin
        VGA_CLKo <= VGA_CLKo + 1;
    end

    /*
     * TV decoder enable
     */
    assign TD_RESET_N =1'b1;

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
	 * Check of any key is pressed
	 */
	wire key_played;
	assign key_played = (sound_in == 88'b0) ? 0 : 1;


    /*
     * 2CH Audio Sound output -- Audio Generater
     */
	audio_codec ad1 (
        // AUDIO CODEC
        .oAUD_BCK  ( AUD_BCLK ),
        .oAUD_DATA ( AUD_DACDAT ),
        .oAUD_LRCK ( AUD_DACLRCK ),
        .iCLK_18_4 ( AUD_CTRL_CLK ),
        // KEY
        .iRST_N      ( KEY[0] ),
        // Sound Control
		.key_pressed ( key_played),
		.sound ( sound_in ),
        .instru ( effects_ctrl ) // Select sound source
    );

endmodule
