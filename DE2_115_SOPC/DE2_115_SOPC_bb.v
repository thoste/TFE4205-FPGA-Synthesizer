
module DE2_115_SOPC (
	clk_clk,
	keyboard_ci_keycode_external,
	keyboard_ci_ps2_read_external,
	pio_keys_external_connection_export,
	pio_led_external_connection_export,
	reset_reset_n,
	synth_effects_ctrl_bus,
	synth_sound_ctrl_bus);	

	input		clk_clk;
	input	[7:0]	keyboard_ci_keycode_external;
	output		keyboard_ci_ps2_read_external;
	input	[17:0]	pio_keys_external_connection_export;
	output	[17:0]	pio_led_external_connection_export;
	input		reset_reset_n;
	output	[17:0]	synth_effects_ctrl_bus;
	output	[87:0]	synth_sound_ctrl_bus;
endmodule
