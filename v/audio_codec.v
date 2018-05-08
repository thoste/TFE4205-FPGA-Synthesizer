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

parameter	NUM_NOTES		=	88;			// Total number of notes avaliable


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
	assign sound_o=music[0]+music[1]+music[2]+music[3]+music[4]+music[5]+music[6]+music[7]+music[8]+music[9]+music[10]+music[11]+music[12]+music[13]+music[14]+music[15]+music[16]+music[17]+music[18]+music[19]+music[20]+music[21]+music[22]+music[23]+music[24]+music[25]+music[26]+music[27]+music[28]+music[29]+music[30]+music[31]+music[32]+music[33]+music[34]+music[35]+music[36]+music[37]+music[38]+music[39]+music[40]+music[41]+music[42]+music[43]+music[44]+music[45]+music[46]+music[47]+music[48]+music[49]+music[50]+music[51]+music[52]+music[53]+music[54]+music[55]+music[56]+music[57]+music[58]+music[59]+music[60]+music[61]+music[62]+music[63]+music[64]+music[65]+music[66]+music[67]+music[68]+music[69]+music[70]+music[71]+music[72]+music[73]+music[74]+music[75]+music[76]+music[77]+music[78]+music[79]+music[80]+music[81]+music[82]+music[83]+music[84]+music[85]+music[86]+music[87];
	
	always@(negedge oAUD_BCK or negedge iRST_N)begin
		if(!iRST_N)
			SEL_Cont	<=	0;
		else
			SEL_Cont	<=	SEL_Cont+1;
	end


/////////// If key pressed, send sound_o to DAC, else send 0 to prevent noise. 
	assign oAUD_DATA = (key_pressed)? sound_o[~SEL_Cont] :0;
	


//////////Wave-Source generate////////////////
	wire [15:0] music [0:NUM_NOTES-1];

	

//////////Ramp//////////////
	reg [15:0] ramp [0:NUM_NOTES-1];
	wire [15:0] ramp_max=60000;
	
	generate 
		genvar i;
		for (i = 0; i < NUM_NOTES; i = i + 1) begin: Ramp_gen
			always@(negedge keys[i] or negedge LRCK_1X) begin
				if (!keys[i]) ramp[i] = 0;
				else if (ramp[i] > ramp_max) ramp[i] = 0;
				else ramp[i] = ramp[i] + freq[i];
			end
		end
	endgenerate



/////////Wave generator////////
	wave_gen s0(
		.ramp(ramp[0][15:10]),
		.effects(effects[3:0]),
		.music_o(music[0])
	);
	wave_gen s1(
		.ramp(ramp[1][15:10]),
		.effects(effects[3:0]),
		.music_o(music[1])
	);
	wave_gen s2(
		.ramp(ramp[2][15:10]),
		.effects(effects[3:0]),
		.music_o(music[2])
	);
	wave_gen s3(
		.ramp(ramp[3][15:10]),
		.effects(effects[3:0]),
		.music_o(music[3])
	);
	wave_gen s4(
		.ramp(ramp[4][15:10]),
		.effects(effects[3:0]),
		.music_o(music[4])
	);
	wave_gen s5(
		.ramp(ramp[5][15:10]),
		.effects(effects[3:0]),
		.music_o(music[5])
	);
	wave_gen s6(
		.ramp(ramp[6][15:10]),
		.effects(effects[3:0]),
		.music_o(music[6])
	);
	wave_gen s7(
		.ramp(ramp[7][15:10]),
		.effects(effects[3:0]),
		.music_o(music[7])
	);
	wave_gen s8(
		.ramp(ramp[8][15:10]),
		.effects(effects[3:0]),
		.music_o(music[8])
	);
	wave_gen s9(
		.ramp(ramp[9][15:10]),
		.effects(effects[3:0]),
		.music_o(music[9])
	);
	wave_gen s10(
		.ramp(ramp[10][15:10]),
		.effects(effects[3:0]),
		.music_o(music[10])
	);
	wave_gen s11(
		.ramp(ramp[11][15:10]),
		.effects(effects[3:0]),
		.music_o(music[11])
	);
	wave_gen s12(
		.ramp(ramp[12][15:10]),
		.effects(effects[3:0]),
		.music_o(music[12])
	);
	wave_gen s13(
		.ramp(ramp[13][15:10]),
		.effects(effects[3:0]),
		.music_o(music[13])
	);
	wave_gen s14(
		.ramp(ramp[14][15:10]),
		.effects(effects[3:0]),
		.music_o(music[14])
	);
	wave_gen s15(
		.ramp(ramp[15][15:10]),
		.effects(effects[3:0]),
		.music_o(music[15])
	);
	wave_gen s16(
		.ramp(ramp[16][15:10]),
		.effects(effects[3:0]),
		.music_o(music[16])
	);
	wave_gen s17(
		.ramp(ramp[17][15:10]),
		.effects(effects[3:0]),
		.music_o(music[17])
	);
	wave_gen s18(
		.ramp(ramp[18][15:10]),
		.effects(effects[3:0]),
		.music_o(music[18])
	);
	wave_gen s19(
		.ramp(ramp[19][15:10]),
		.effects(effects[3:0]),
		.music_o(music[19])
	);
	wave_gen s20(
		.ramp(ramp[20][15:10]),
		.effects(effects[3:0]),
		.music_o(music[20])
	);
	wave_gen s21(
		.ramp(ramp[21][15:10]),
		.effects(effects[3:0]),
		.music_o(music[21])
	);
	wave_gen s22(
		.ramp(ramp[22][15:10]),
		.effects(effects[3:0]),
		.music_o(music[22])
	);
	wave_gen s23(
		.ramp(ramp[23][15:10]),
		.effects(effects[3:0]),
		.music_o(music[23])
	);
	wave_gen s24(
		.ramp(ramp[24][15:10]),
		.effects(effects[3:0]),
		.music_o(music[24])
	);
	wave_gen s25(
		.ramp(ramp[25][15:10]),
		.effects(effects[3:0]),
		.music_o(music[25])
	);
	wave_gen s26(
		.ramp(ramp[26][15:10]),
		.effects(effects[3:0]),
		.music_o(music[26])
	);
	wave_gen s27(
		.ramp(ramp[27][15:10]),
		.effects(effects[3:0]),
		.music_o(music[27])
	);
	wave_gen s28(
		.ramp(ramp[28][15:10]),
		.effects(effects[3:0]),
		.music_o(music[28])
	);
	wave_gen s29(
		.ramp(ramp[29][15:10]),
		.effects(effects[3:0]),
		.music_o(music[29])
	);
	wave_gen s30(
		.ramp(ramp[30][15:10]),
		.effects(effects[3:0]),
		.music_o(music[30])
	);
	wave_gen s31(
		.ramp(ramp[31][15:10]),
		.effects(effects[3:0]),
		.music_o(music[31])
	);
	wave_gen s32(
		.ramp(ramp[32][15:10]),
		.effects(effects[3:0]),
		.music_o(music[32])
	);
	wave_gen s33(
		.ramp(ramp[33][15:10]),
		.effects(effects[3:0]),
		.music_o(music[33])
	);
	wave_gen s34(
		.ramp(ramp[34][15:10]),
		.effects(effects[3:0]),
		.music_o(music[34])
	);
	wave_gen s35(
		.ramp(ramp[35][15:10]),
		.effects(effects[3:0]),
		.music_o(music[35])
	);
	wave_gen s36(
		.ramp(ramp[36][15:10]),
		.effects(effects[3:0]),
		.music_o(music[36])
	);
	wave_gen s37(
		.ramp(ramp[37][15:10]),
		.effects(effects[3:0]),
		.music_o(music[37])
	);
	wave_gen s38(
		.ramp(ramp[38][15:10]),
		.effects(effects[3:0]),
		.music_o(music[38])
	);
	wave_gen s39(
		.ramp(ramp[39][15:10]),
		.effects(effects[3:0]),
		.music_o(music[39])
	);
	wave_gen s40(
		.ramp(ramp[40][15:10]),
		.effects(effects[3:0]),
		.music_o(music[40])
	);
	wave_gen s41(
		.ramp(ramp[41][15:10]),
		.effects(effects[3:0]),
		.music_o(music[41])
	);
	wave_gen s42(
		.ramp(ramp[42][15:10]),
		.effects(effects[3:0]),
		.music_o(music[42])
	);
	wave_gen s43(
		.ramp(ramp[43][15:10]),
		.effects(effects[3:0]),
		.music_o(music[43])
	);
	wave_gen s44(
		.ramp(ramp[44][15:10]),
		.effects(effects[3:0]),
		.music_o(music[44])
	);
	wave_gen s45(
		.ramp(ramp[45][15:10]),
		.effects(effects[3:0]),
		.music_o(music[45])
	);
	wave_gen s46(
		.ramp(ramp[46][15:10]),
		.effects(effects[3:0]),
		.music_o(music[46])
	);
	wave_gen s47(
		.ramp(ramp[47][15:10]),
		.effects(effects[3:0]),
		.music_o(music[47])
	);
	wave_gen s48(
		.ramp(ramp[48][15:10]),
		.effects(effects[3:0]),
		.music_o(music[48])
	);
	wave_gen s49(
		.ramp(ramp[49][15:10]),
		.effects(effects[3:0]),
		.music_o(music[49])
	);
	wave_gen s50(
		.ramp(ramp[50][15:10]),
		.effects(effects[3:0]),
		.music_o(music[50])
	);
	wave_gen s51(
		.ramp(ramp[51][15:10]),
		.effects(effects[3:0]),
		.music_o(music[51])
	);
	wave_gen s52(
		.ramp(ramp[52][15:10]),
		.effects(effects[3:0]),
		.music_o(music[52])
	);
	wave_gen s53(
		.ramp(ramp[53][15:10]),
		.effects(effects[3:0]),
		.music_o(music[53])
	);
	wave_gen s54(
		.ramp(ramp[54][15:10]),
		.effects(effects[3:0]),
		.music_o(music[54])
	);
	wave_gen s55(
		.ramp(ramp[55][15:10]),
		.effects(effects[3:0]),
		.music_o(music[55])
	);
	wave_gen s56(
		.ramp(ramp[56][15:10]),
		.effects(effects[3:0]),
		.music_o(music[56])
	);
	wave_gen s57(
		.ramp(ramp[57][15:10]),
		.effects(effects[3:0]),
		.music_o(music[57])
	);
	wave_gen s58(
		.ramp(ramp[58][15:10]),
		.effects(effects[3:0]),
		.music_o(music[58])
	);
	wave_gen s59(
		.ramp(ramp[59][15:10]),
		.effects(effects[3:0]),
		.music_o(music[59])
	);
	wave_gen s60(
		.ramp(ramp[60][15:10]),
		.effects(effects[3:0]),
		.music_o(music[60])
	);
	wave_gen s61(
		.ramp(ramp[61][15:10]),
		.effects(effects[3:0]),
		.music_o(music[61])
	);
	wave_gen s62(
		.ramp(ramp[62][15:10]),
		.effects(effects[3:0]),
		.music_o(music[62])
	);
	wave_gen s63(
		.ramp(ramp[63][15:10]),
		.effects(effects[3:0]),
		.music_o(music[63])
	);
	wave_gen s64(
		.ramp(ramp[64][15:10]),
		.effects(effects[3:0]),
		.music_o(music[64])
	);
	wave_gen s65(
		.ramp(ramp[65][15:10]),
		.effects(effects[3:0]),
		.music_o(music[65])
	);
	wave_gen s66(
		.ramp(ramp[66][15:10]),
		.effects(effects[3:0]),
		.music_o(music[66])
	);
	wave_gen s67(
		.ramp(ramp[67][15:10]),
		.effects(effects[3:0]),
		.music_o(music[67])
	);
	wave_gen s68(
		.ramp(ramp[68][15:10]),
		.effects(effects[3:0]),
		.music_o(music[68])
	);
	wave_gen s69(
		.ramp(ramp[69][15:10]),
		.effects(effects[3:0]),
		.music_o(music[69])
	);
	wave_gen s70(
		.ramp(ramp[70][15:10]),
		.effects(effects[3:0]),
		.music_o(music[70])
	);
	wave_gen s71(
		.ramp(ramp[71][15:10]),
		.effects(effects[3:0]),
		.music_o(music[71])
	);
	wave_gen s72(
		.ramp(ramp[72][15:10]),
		.effects(effects[3:0]),
		.music_o(music[72])
	);
	wave_gen s73(
		.ramp(ramp[73][15:10]),
		.effects(effects[3:0]),
		.music_o(music[73])
	);
	wave_gen s74(
		.ramp(ramp[74][15:10]),
		.effects(effects[3:0]),
		.music_o(music[74])
	);
	wave_gen s75(
		.ramp(ramp[75][15:10]),
		.effects(effects[3:0]),
		.music_o(music[75])
	);
	wave_gen s76(
		.ramp(ramp[76][15:10]),
		.effects(effects[3:0]),
		.music_o(music[76])
	);
	wave_gen s77(
		.ramp(ramp[77][15:10]),
		.effects(effects[3:0]),
		.music_o(music[77])
	);
	wave_gen s78(
		.ramp(ramp[78][15:10]),
		.effects(effects[3:0]),
		.music_o(music[78])
	);
	wave_gen s79(
		.ramp(ramp[79][15:10]),
		.effects(effects[3:0]),
		.music_o(music[79])
	);
	wave_gen s80(
		.ramp(ramp[80][15:10]),
		.effects(effects[3:0]),
		.music_o(music[80])
	);
	wave_gen s81(
		.ramp(ramp[81][15:10]),
		.effects(effects[3:0]),
		.music_o(music[81])
	);
	wave_gen s82(
		.ramp(ramp[82][15:10]),
		.effects(effects[3:0]),
		.music_o(music[82])
	);
	wave_gen s83(
		.ramp(ramp[83][15:10]),
		.effects(effects[3:0]),
		.music_o(music[83])
	);
	wave_gen s84(
		.ramp(ramp[84][15:10]),
		.effects(effects[3:0]),
		.music_o(music[84])
	);
	wave_gen s85(
		.ramp(ramp[85][15:10]),
		.effects(effects[3:0]),
		.music_o(music[85])
	);
	wave_gen s86(
		.ramp(ramp[86][15:10]),
		.effects(effects[3:0]),
		.music_o(music[86])
	);
	wave_gen s87(
		.ramp(ramp[87][15:10]),
		.effects(effects[3:0]),
		.music_o(music[87])
	);
	
	/***************************************************************************
     *
     * Frequencies
     *
     **************************************************************************/
	wire [15:0] freq [0:NUM_NOTES-1];
	
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