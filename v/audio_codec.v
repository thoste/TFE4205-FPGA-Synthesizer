module audio_codec (
output			oAUD_DATA,
output			oAUD_LRCK,
output	reg		oAUD_BCK,

input			iCLK_18_4,
input			iRST_N,

input 			key_pressed,	// Any key pressed
input	[87:0]	keys,			// Keys pressed
input   [17:0]  effects 		// Select sound wave on bit [3:0]

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


////////////Timbre selection & SoundOut///////////////
	wire [15:0]sound_o;
	assign sound_o=music1+music2+music3+music4+music5+music6+music7+music8+music9+music10+music11+music12;	
	
	always@(negedge oAUD_BCK or negedge iRST_N)begin
		if(!iRST_N)
			SEL_Cont	<=	0;
		else
			SEL_Cont	<=	SEL_Cont+1;
	end
	
	// If key pressed, send sound_o to DAC, else send 0 to prevent noise. 
	assign oAUD_DATA = (key_pressed)? sound_o[~SEL_Cont] :0;
	


///////////////////Wave-Source generate////////////////
	wire [15:0]music1_sin;
	wire [15:0]music2_sin;
	wire [15:0]music3_sin;
	wire [15:0]music4_sin;
	wire [15:0]music5_sin;
	wire [15:0]music6_sin;
	wire [15:0]music7_sin;
	wire [15:0]music8_sin;
	wire [15:0]music9_sin;
	wire [15:0]music10_sin;
	wire [15:0]music11_sin;
	wire [15:0]music12_sin;
	
	wire [15:0]music1_square;
	wire [15:0]music2_square;
	wire [15:0]music3_square;
	wire [15:0]music4_square;
	wire [15:0]music5_square;
	wire [15:0]music6_square;
	wire [15:0]music7_square;
	wire [15:0]music8_square;
	wire [15:0]music9_square;
	wire [15:0]music10_square;
	wire [15:0]music11_square;
	wire [15:0]music12_square;
	
	wire [15:0]music1;
	wire [15:0]music2;
	wire [15:0]music3;
	wire [15:0]music4;
	wire [15:0]music5;
	wire [15:0]music6;
	wire [15:0]music7;
	wire [15:0]music8;
	wire [15:0]music9;
	wire [15:0]music10;
	wire [15:0]music11;
	wire [15:0]music12;
	
	assign music1 = (effects == 18'b01) ? music1_sin :
					(effects == 18'b10) ? music1_square :
										 music1_sin;
	assign music2 = (effects == 18'b01) ? music2_sin :
					(effects == 18'b10) ? music2_square :
										 music2_sin;
	assign music3 = (effects == 18'b01) ? music3_sin :
					(effects == 18'b10) ? music3_square :
										 music3_sin;
	assign music4 = (effects == 18'b01) ? music4_sin :
					(effects == 18'b10) ? music4_square :
										 music4_sin;		
	assign music5 = (effects == 18'b01) ? music5_sin :
					(effects == 18'b10) ? music5_square :
										 music5_sin;
	assign music6 = (effects == 18'b01) ? music6_sin :
					(effects == 18'b10) ? music6_square :
										 music6_sin;
	assign music7 = (effects == 18'b01) ? music7_sin :
					(effects == 18'b10) ? music7_square :
										 music7_sin;
	assign music8 = (effects == 18'b01) ? music8_sin :
					(effects == 18'b10) ? music8_square :
										 music8_sin;	
	assign music9 = (effects == 18'b01) ? music9_sin :
					(effects == 18'b10) ? music9_square :
										 music9_sin;
	assign music10 = (effects == 18'b01) ? music10_sin :
					 (effects == 18'b10) ? music10_square :
										  music10_sin;
	assign music11 = (effects == 18'b01) ? music11_sin :
					 (effects == 18'b10) ? music11_square :
										  music11_sin;
	assign music12 = (effects == 18'b01) ? music12_sin :
					 (effects == 18'b10) ? music12_square :
										  music12_sin;								



//////////Ramp address generater//////////////
	reg  [15:0]ramp1;
	reg  [15:0]ramp2;
	reg  [15:0]ramp3;
	reg  [15:0]ramp4;
	reg  [15:0]ramp5;
	reg  [15:0]ramp6;
	reg  [15:0]ramp7;
	reg  [15:0]ramp8;
	reg  [15:0]ramp9;
	reg  [15:0]ramp10;
	reg  [15:0]ramp11;
	reg  [15:0]ramp12;
	wire [15:0]ramp_max=60000;
	
//////Ramps//////
	always@(negedge keys[0] or negedge LRCK_1X)begin
	if (!keys[0]) ramp1=0;
	else if (ramp1>ramp_max) ramp1=0;
	else ramp1 = ramp1 + freq[39];
	end

	always@(negedge keys[1] or negedge LRCK_1X)begin
	if (!keys[1]) ramp2=0;
	else if (ramp2>ramp_max) ramp2=0;
	else ramp2 = ramp2 + freq[40];
	end

	always@(negedge keys[2] or negedge LRCK_1X)begin
	if (!keys[2]) ramp3=0;
	else if (ramp3>ramp_max) ramp3=0;
	else ramp3 = ramp3 + freq[41];
	end

	always@(negedge keys[3] or negedge LRCK_1X)begin
	if (!keys[3]) ramp4=0;
	else if (ramp4>ramp_max) ramp4=0;
	else ramp4 = ramp4 + freq[42];
	end
	always@(negedge keys[4] or negedge LRCK_1X)begin
	if (!keys[4]) ramp5=0;
	else if (ramp5>ramp_max) ramp5=0;
	else ramp5 = ramp5 + freq[43];
	end

	always@(negedge keys[5] or negedge LRCK_1X)begin
	if (!keys[5]) ramp6=0;
	else if (ramp6>ramp_max) ramp6=0;
	else ramp6 = ramp6 + freq[44];
	end

	always@(negedge keys[6] or negedge LRCK_1X)begin
	if (!keys[6]) ramp7=0;
	else if (ramp7>ramp_max) ramp7=0;
	else ramp7 = ramp7 + freq[6];
	end

	always@(negedge keys[7] or negedge LRCK_1X)begin
	if (!keys[7]) ramp8=0;
	else if (ramp8>ramp_max) ramp8=0;
	else ramp8 = ramp8 + freq[7];
	end
	always@(negedge keys[8] or negedge LRCK_1X)begin
	if (!keys[8]) ramp9=0;
	else if (ramp9>ramp_max) ramp9=0;
	else ramp9 = ramp9 + freq[8];
	end

	always@(negedge keys[9] or negedge LRCK_1X)begin
	if (!keys[9]) ramp10=0;
	else if (ramp10>ramp_max) ramp10=0;
	else ramp10 = ramp10 + freq[9];
	end

	always@(negedge keys[10] or negedge LRCK_1X)begin
	if (!keys[10]) ramp11=0;
	else if (ramp11>ramp_max) ramp11=0;
	else ramp11 = ramp11 + freq[10];
	end

	always@(negedge keys[11] or negedge LRCK_1X)begin
	if (!keys[11]) ramp12=0;
	else if (ramp12>ramp_max) ramp12=0;
	else ramp12 = ramp12 + freq[11];
	end
	
	
////////////Ramp address assign//////////////
	wire [5:0]ramp1_sin=(effects==18'b0001)?ramp1[15:10]:0;
	wire [5:0]ramp2_sin=(effects==18'b0001)?ramp2[15:10]:0;
	wire [5:0]ramp3_sin=(effects==18'b0001)?ramp3[15:10]:0;
	wire [5:0]ramp4_sin=(effects==18'b0001)?ramp4[15:10]:0;
	wire [5:0]ramp5_sin=(effects==18'b0001)?ramp5[15:10]:0;
	wire [5:0]ramp6_sin=(effects==18'b0001)?ramp6[15:10]:0;
	wire [5:0]ramp7_sin=(effects==18'b0001)?ramp7[15:10]:0;
	wire [5:0]ramp8_sin=(effects==18'b0001)?ramp8[15:10]:0;
	wire [5:0]ramp9_sin=(effects==18'b0001)?ramp9[15:10]:0;
	wire [5:0]ramp10_sin=(effects==18'b0001)?ramp10[15:10]:0;
	wire [5:0]ramp11_sin=(effects==18'b0001)?ramp11[15:10]:0;
	wire [5:0]ramp12_sin=(effects==18'b0001)?ramp12[15:10]:0;
	
	wire [5:0]ramp1_square=(effects==18'b0010)?ramp1[15:10]:0;
	wire [5:0]ramp2_square=(effects==18'b0010)?ramp2[15:10]:0;
	wire [5:0]ramp3_square=(effects==18'b0010)?ramp3[15:10]:0;
	wire [5:0]ramp4_square=(effects==18'b0010)?ramp4[15:10]:0;
	wire [5:0]ramp5_square=(effects==18'b0010)?ramp5[15:10]:0;
	wire [5:0]ramp6_square=(effects==18'b0010)?ramp6[15:10]:0;
	wire [5:0]ramp7_square=(effects==18'b0010)?ramp7[15:10]:0;
	wire [5:0]ramp8_square=(effects==18'b0010)?ramp8[15:10]:0;
	wire [5:0]ramp9_square=(effects==18'b0010)?ramp9[15:10]:0;
	wire [5:0]ramp10_square=(effects==18'b0010)?ramp10[15:10]:0;
	wire [5:0]ramp11_square=(effects==18'b0010)?ramp11[15:10]:0;
	wire [5:0]ramp12_square=(effects==18'b0010)?ramp12[15:10]:0;




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
		wave_gen_sin s5(
		.ramp(ramp5_sin),
		.music_o(music5_sin)
	);
	wave_gen_sin s6(
		.ramp(ramp6_sin),
		.music_o(music6_sin)
	);
	wave_gen_sin s7(
		.ramp(ramp7_sin),
		.music_o(music7_sin)
	);
	wave_gen_sin s8(
		.ramp(ramp8_sin),
		.music_o(music8_sin)
	);
		wave_gen_sin s9(
		.ramp(ramp9_sin),
		.music_o(music9_sin)
	);
	wave_gen_sin s10(
		.ramp(ramp10_sin),
		.music_o(music10_sin)
	);
	wave_gen_sin s11(
		.ramp(ramp11_sin),
		.music_o(music11_sin)
	);
	wave_gen_sin s12(
		.ramp(ramp12_sin),
		.music_o(music12_sin)
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
	wave_gen_square sq5(
		.ramp(ramp5_square),
		.music_o(music5_square)
	);
	wave_gen_square sq6(
		.ramp(ramp6_square),
		.music_o(music6_square)
	);
	wave_gen_square sq7(
		.ramp(ramp7_square),
		.music_o(music7_square)
	);
	wave_gen_square sq8(
		.ramp(ramp8_square),
		.music_o(music8_square)
	);
	wave_gen_square sq9(
		.ramp(ramp9_square),
		.music_o(music9_square)
	);
	wave_gen_square sq10(
		.ramp(ramp10_square),
		.music_o(music10_square)
	);
	wave_gen_square sq11(
		.ramp(ramp11_square),
		.music_o(music11_square)
	);
	wave_gen_square sq12(
		.ramp(ramp12_square),
		.music_o(music12_square)
	);
	
	
	/***************************************************************************
     *
     * Frequencies
     *
     **************************************************************************/
	wire [15:0] freq [0:87];
	
	assign freq[87] = 4186;
    assign freq[86] = 3951;
    assign freq[85] = 3729;
    assign freq[84] = 3520;
    assign freq[83] = 3322;
    assign freq[82] = 3135;
    assign freq[81] = 2959;
    assign freq[80] = 2793;
    assign freq[79] = 2637;
    assign freq[78] = 2489;
    assign freq[77] = 2349;
    assign freq[76] = 2217;
    assign freq[75] = 2093;
    assign freq[74] = 1975;
    assign freq[73] = 1864;
    assign freq[72] = 1760;
    assign freq[71] = 1661;
    assign freq[70] = 1567;
    assign freq[69] = 1479;
    assign freq[68] = 1396;
    assign freq[67] = 1318;
    assign freq[66] = 1244;
    assign freq[65] = 1174;
    assign freq[64] = 1108;
    assign freq[63] = 1046;
    assign freq[62] = 987;
    assign freq[61] = 932;
    assign freq[60] = 880;
    assign freq[59] = 830;
    assign freq[58] = 783;
    assign freq[57] = 739;
    assign freq[56] = 698;
    assign freq[55] = 659;
    assign freq[54] = 622;
    assign freq[53] = 587;
    assign freq[52] = 554;
    assign freq[51] = 523;
    assign freq[50] = 493;
    assign freq[49] = 466;
    assign freq[48] = 440;
    assign freq[47] = 415;
    assign freq[46] = 391;
    assign freq[45] = 369;
    assign freq[44] = 349;
    assign freq[43] = 329;
    assign freq[42] = 311;
    assign freq[41] = 293;
    assign freq[40] = 277;
    assign freq[39] = 261;
    assign freq[38] = 246;
    assign freq[37] = 233;
    assign freq[36] = 220;
    assign freq[35] = 207;
    assign freq[34] = 195;
    assign freq[33] = 184;
    assign freq[32] = 174;
    assign freq[31] = 164;
    assign freq[30] = 155;
    assign freq[29] = 146;
    assign freq[28] = 138;
    assign freq[27] = 130;
    assign freq[26] = 123;
    assign freq[25] = 116;
    assign freq[24] = 110;
    assign freq[23] = 103;
    assign freq[22] = 97;
    assign freq[21] = 92;
    assign freq[20] = 87;
    assign freq[19] = 82;
    assign freq[18] = 77;
    assign freq[17] = 73;
    assign freq[16] = 69;
    assign freq[15] = 65;
    assign freq[14] = 61;
    assign freq[13] = 58;
    assign freq[12] = 55;
    assign freq[11] = 51;
    assign freq[10] = 48;
    assign freq[9] = 46;
    assign freq[8] = 43;
    assign freq[7] = 41;
    assign freq[6] = 38;
    assign freq[5] = 36;
    assign freq[4] = 34;
    assign freq[3] = 32;
    assign freq[2] = 30;
    assign freq[1] = 29;
    assign freq[0] = 27;
	
	/*
    parameter C8  = 4186;
    parameter B7  = 3951;
    parameter Bb7 = 3729;
    parameter A7  = 3520;
    parameter Ab7 = 3322;
    parameter G7  = 3135;
    parameter Gb7 = 2959;
    parameter F7  = 2793;
    parameter E7  = 2637;
    parameter Eb7 = 2489;
    parameter D7  = 2349;
    parameter Db7 = 2217;
    parameter C7  = 2093;
    parameter B6  = 1975;
    parameter Bb6 = 1864;
    parameter A6  = 1760;
    parameter Ab6 = 1661;
    parameter G6  = 1567;
    parameter Gb6 = 1479;
    parameter F6  = 1396;
    parameter E6  = 1318;
    parameter Eb6 = 1244;
    parameter D6  = 1174;
    parameter Db6 = 1108;
    parameter C6  = 1046;
    parameter B5  = 987;
    parameter Bb5 = 932;
    parameter A5  = 880;
    parameter Ab5 = 830;
    parameter G5  = 783;
    parameter Gb5 = 739;
    parameter F5  = 698;
    parameter E5  = 659;
    parameter Eb5 = 622;
    parameter D5  = 587;
    parameter Db5 = 554;
    parameter C5  = 523;
    parameter B4  = 493;
    parameter Bb4 = 466;
    parameter A4  = 440;
    parameter Ab4 = 415;
    parameter G4  = 391;
    parameter Gb4 = 369;
    parameter F4  = 349;
    parameter E4  = 329;
    parameter Eb4 = 311;
    parameter D4  = 293;
    parameter Db4 = 277;
    parameter C4  = 261;
    parameter B3  = 246;
    parameter Bb3 = 233;
    parameter A3  = 220;
    parameter Ab3 = 207;
    parameter G3  = 195;
    parameter Gb3 = 184;
    parameter F3  = 174;
    parameter E3  = 164;
    parameter Eb3 = 155;
    parameter D3  = 146;
    parameter Db3 = 138;
    parameter C3  = 130;
    parameter B2  = 123;
    parameter Bb2 = 116;
    parameter A2  = 110;
    parameter Ab2 = 103;
    parameter G2  = 97;
    parameter Gb2 = 92;
    parameter F2  = 87;
    parameter E2  = 82;
    parameter Eb2 = 77;
    parameter D2  = 73;
    parameter Db2 = 69;
    parameter C2  = 65;
    parameter B1  = 61;
    parameter Bb1 = 58;
    parameter A1  = 55;
    parameter Ab1 = 51;
    parameter G1  = 48;
    parameter Gb1 = 46;
    parameter F1  = 43;
    parameter E1  = 41;
    parameter Eb1 = 38;
    parameter D1  = 36;
    parameter Db1 = 34;
    parameter C1  = 32;
    parameter B0  = 30;
    parameter Bb0 = 29;
    parameter A0  = 27;
	*/
endmodule