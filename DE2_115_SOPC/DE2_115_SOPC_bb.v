
module DE2_115_SOPC (
	clk_clk,
	pio_keys_external_connection_export,
	pio_led_external_connection_export,
	reset_reset_n,
	pio_sound_external_connection_export);	

	input		clk_clk;
	input	[3:0]	pio_keys_external_connection_export;
	output	[7:0]	pio_led_external_connection_export;
	input		reset_reset_n;
	output	[15:0]	pio_sound_external_connection_export;
endmodule
