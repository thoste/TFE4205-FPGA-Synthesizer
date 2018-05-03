
module DE2_115_SOPC (
	clk_clk,
	pio_keys_external_connection_export,
	pio_led_external_connection_export,
	reset_reset_n,
	synth_effects_ctrl_effects_ctrl_bus,
	synth_sounds_ctrl_sound_ctrl_bus,
	pio_keyboard_external_connection_export);	

	input		clk_clk;
	input	[3:0]	pio_keys_external_connection_export;
	output	[7:0]	pio_led_external_connection_export;
	input		reset_reset_n;
	output	[17:0]	synth_effects_ctrl_effects_ctrl_bus;
	output	[87:0]	synth_sounds_ctrl_sound_ctrl_bus;
	input	[7:0]	pio_keyboard_external_connection_export;
endmodule
