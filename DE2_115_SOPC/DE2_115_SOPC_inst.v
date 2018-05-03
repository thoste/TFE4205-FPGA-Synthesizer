	DE2_115_SOPC u0 (
		.clk_clk                                 (<connected-to-clk_clk>),                                 //                              clk.clk
		.pio_keys_external_connection_export     (<connected-to-pio_keys_external_connection_export>),     //     pio_keys_external_connection.export
		.pio_led_external_connection_export      (<connected-to-pio_led_external_connection_export>),      //      pio_led_external_connection.export
		.reset_reset_n                           (<connected-to-reset_reset_n>),                           //                            reset.reset_n
		.synth_effects_ctrl_effects_ctrl_bus     (<connected-to-synth_effects_ctrl_effects_ctrl_bus>),     //               synth_effects_ctrl.effects_ctrl_bus
		.synth_sounds_ctrl_sound_ctrl_bus        (<connected-to-synth_sounds_ctrl_sound_ctrl_bus>),        //                synth_sounds_ctrl.sound_ctrl_bus
		.pio_keyboard_external_connection_export (<connected-to-pio_keyboard_external_connection_export>)  // pio_keyboard_external_connection.export
	);

