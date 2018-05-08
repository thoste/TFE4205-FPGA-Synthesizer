	DE2_115_SOPC u0 (
		.clk_clk                             (<connected-to-clk_clk>),                             //                          clk.clk
		.keyboard_ci_keycode_external        (<connected-to-keyboard_ci_keycode_external>),        //          keyboard_ci_keycode.external
		.keyboard_ci_ps2_read_external       (<connected-to-keyboard_ci_ps2_read_external>),       //         keyboard_ci_ps2_read.external
		.pio_keys_external_connection_export (<connected-to-pio_keys_external_connection_export>), // pio_keys_external_connection.export
		.pio_led_external_connection_export  (<connected-to-pio_led_external_connection_export>),  //  pio_led_external_connection.export
		.reset_reset_n                       (<connected-to-reset_reset_n>),                       //                        reset.reset_n
		.synth_effects_ctrl_bus              (<connected-to-synth_effects_ctrl_bus>),              //           synth_effects_ctrl.bus
		.synth_sound_ctrl_bus                (<connected-to-synth_sound_ctrl_bus>)                 //             synth_sound_ctrl.bus
	);

