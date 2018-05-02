module adio_codec (
output			oAUD_DATA,
output			oAUD_LRCK,
output	reg		oAUD_BCK,
//input key1_on,
//input key2_on,
//input key3_on,
//input key4_on,
input key_on,

input			iCLK_18_4,
input			iRST_N,
//input   [15:0]	sound1,
//input   [15:0]	sound2,
//input   [15:0]	sound3,
//input   [15:0]	sound4,
input	[87:0]	sound,
// Select sound
input   [17:0]   instru

						);				

parameter	REF_CLK			=	18432000;	//	18.432	MHz
parameter	SAMPLE_RATE		=	48000;		//	48		KHz
parameter	DATA_WIDTH		=	16;			//	16		Bits
parameter	CHANNEL_NUM		=	2;			//	Dual Channel

parameter	SIN_SAMPLE_DATA	=	48;


//////////////////////////////////////////////////
//	Internal Registers and Wires
reg		[3:0]	BCK_DIV;
reg		[8:0]	LRCK_1X_DIV;
reg		[7:0]	LRCK_2X_DIV;
reg		[6:0]	LRCK_4X_DIV;
reg		[3:0]	SEL_Cont;
////////	DATA Counter	////////
reg		[5:0]	SIN_Cont;
////////////////////////////////////
reg							LRCK_1X;
reg							LRCK_2X;
reg							LRCK_4X;

////////////	AUD_BCK Generator	//////////////
always@(posedge iCLK_18_4 or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		BCK_DIV		<=	0;
		oAUD_BCK	<=	0;
	end
	else
	begin
		if(BCK_DIV >= REF_CLK/(SAMPLE_RATE*DATA_WIDTH*CHANNEL_NUM*2)-1 )
		begin
			BCK_DIV		<=	0;
			oAUD_BCK	<=	~oAUD_BCK;
		end
		else
		BCK_DIV		<=	BCK_DIV+1;
	end
end
//////////////////////////////////////////////////
////////////	AUD_LRCK Generator	//////////////
always@(posedge iCLK_18_4 or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		LRCK_1X_DIV	<=	0;
		LRCK_2X_DIV	<=	0;
		LRCK_4X_DIV	<=	0;
		LRCK_1X		<=	0;
		LRCK_2X		<=	0;
		LRCK_4X		<=	0;
	end
	else
	begin
		//	LRCK 1X
		if(LRCK_1X_DIV >= REF_CLK/(SAMPLE_RATE*2)-1 )
		begin
			LRCK_1X_DIV	<=	0;
			LRCK_1X	<=	~LRCK_1X;
		end
		else
		LRCK_1X_DIV		<=	LRCK_1X_DIV+1;
		//	LRCK 2X
		if(LRCK_2X_DIV >= REF_CLK/(SAMPLE_RATE*4)-1 )
		begin
			LRCK_2X_DIV	<=	0;
			LRCK_2X	<=	~LRCK_2X;
		end
		else
		LRCK_2X_DIV		<=	LRCK_2X_DIV+1;		
		//	LRCK 4X
		if(LRCK_4X_DIV >= REF_CLK/(SAMPLE_RATE*8)-1 )
		begin
			LRCK_4X_DIV	<=	0;
			LRCK_4X	<=	~LRCK_4X;
		end
		else
		LRCK_4X_DIV		<=	LRCK_4X_DIV+1;		
	end
end
assign	oAUD_LRCK	=	LRCK_1X;
//////////////////////////////////////////////////
//////////	Sin LUT ADDR Generator	//////////////
always@(negedge LRCK_1X or negedge iRST_N)
begin
	if(!iRST_N)
	SIN_Cont	<=	0;
	else
	begin
		if(SIN_Cont < SIN_SAMPLE_DATA-1 )
		SIN_Cont	<=	SIN_Cont+1;
		else
		SIN_Cont	<=	0;
	end
end


///////////////////Wave-Source generate////////////////
////////////Timbre selection & SoundOut///////////////
	wire [15:0]music1_ramp;
	wire [15:0]music2_ramp;
	wire [15:0]music3_ramp;
	wire [15:0]music4_ramp;
	wire [15:0]music1_sin;
	wire [15:0]music2_sin;
	wire [15:0]music3_sin;
	wire [15:0]music4_sin;
	wire [15:0]music1_square;
	wire [15:0]music2_square;
	wire [15:0]music3_square;
	wire [15:0]music4_square;
	
	wire [15:0]music1;
	wire [15:0]music2;
	wire [15:0]music3;
	wire [15:0]music4;
	
	assign music1 = (instru == 18'b01) ? music1_sin :
					(instru == 18'b10) ? music1_square :
										music1_sin;
	assign music2 = (instru == 18'b01) ? music2_sin :
					(instru == 18'b10) ? music2_square :
										music2_sin;
	assign music3 = (instru == 18'b01) ? music3_sin :
					(instru == 18'b10) ? music3_square :
										music3_sin;
	assign music4 = (instru == 18'b01) ? music4_sin :
					(instru == 18'b10) ? music4_square :
										music4_sin;									
	
	wire [15:0]sound_o;
	assign sound_o=music1+music2+music3+music4;	
	
	always@(negedge oAUD_BCK or negedge iRST_N)begin
		if(!iRST_N)
			SEL_Cont	<=	0;
		else
			SEL_Cont	<=	SEL_Cont+1;
	end
	
	// If key pressed, send sound_o, else send 0 to DAC to prevent noise. 
	assign	oAUD_DATA = (key_on)? sound_o[~SEL_Cont] :0;

//////////Ramp address generater//////////////
	reg  [15:0]ramp1;
	reg  [15:0]ramp2;
	reg  [15:0]ramp3;
	reg  [15:0]ramp4;
	wire [15:0]ramp_max=60000;
	
//////CH1 Ramp//////
	always@(negedge sound[0] or negedge LRCK_1X)begin
	if (!sound[0])
		ramp1=0;
	else if (ramp1>ramp_max) ramp1=0;
	else ramp1 = ramp1 + A4;
	end

//////CH2 Ramp//////
	always@(negedge sound[1] or negedge LRCK_1X)begin
	if (!sound[1])
		ramp2=0;
	else if (ramp2>ramp_max) ramp2=0;
	else ramp2 = ramp2 + Db5;
	end

//////CH3 Ramp/////
	always@(negedge sound[2] or negedge LRCK_1X)begin
	if (!sound[2])
		ramp3=0;
	else if (ramp3>ramp_max) ramp3=0;
	else ramp3 = ramp3 + E5;
	end

//////CH4 Ramp/////
	always@(negedge sound[3] or negedge LRCK_1X)begin
	if (!sound[3])
		ramp4=0;
	else if (ramp4>ramp_max) ramp4=0;
	else ramp4 = ramp4 + A5;
	end

////////////Ramp address assign//////////////
	wire [5:0]ramp1_sin=(instru==18'b0001)?ramp1[15:10]:0;
	wire [5:0]ramp2_sin=(instru==18'b0001)?ramp2[15:10]:0;
	wire [5:0]ramp3_sin=(instru==18'b0001)?ramp3[15:10]:0;
	wire [5:0]ramp4_sin=(instru==18'b0001)?ramp4[15:10]:0;
	wire [5:0]ramp1_square=(instru==18'b0010)?ramp1[15:10]:0;
	wire [5:0]ramp2_square=(instru==18'b0010)?ramp2[15:10]:0;
	wire [5:0]ramp3_square=(instru==18'b0010)?ramp3[15:10]:0;
	wire [5:0]ramp4_square=(instru==18'b0010)?ramp4[15:10]:0;




/////////Sine-wave Timbre////////
	wave_gen_sin s1(
		.ramp(ramp1_sin),
		.music_o(music1_sin)
	);
	wave_gen_sin s2(
		.ramp(ramp2_sin),
		.music_o(music2_sin)
	);
	wave_gen_sin s3(
		.ramp(ramp3_sin),
		.music_o(music3_sin)
	);
	wave_gen_sin s4(
		.ramp(ramp4_sin),
		.music_o(music4_sin)
	);

	/////////Square-wave Timbre////////
	wave_gen_square sq1(
		.ramp(ramp1_square),
		.music_o(music1_square)
	);
	wave_gen_square sq2(
		.ramp(ramp2_square),
		.music_o(music2_square)
	);
	wave_gen_square sq3(
		.ramp(ramp3_square),
		.music_o(music3_square)
	);
	wave_gen_square sq4(
		.ramp(ramp4_square),
		.music_o(music4_square)
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
	
endmodule