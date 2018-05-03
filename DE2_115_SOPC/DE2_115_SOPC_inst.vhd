	component DE2_115_SOPC is
		port (
			clk_clk                                 : in  std_logic                     := 'X';             -- clk
			pio_keys_external_connection_export     : in  std_logic_vector(3 downto 0)  := (others => 'X'); -- export
			pio_led_external_connection_export      : out std_logic_vector(7 downto 0);                     -- export
			reset_reset_n                           : in  std_logic                     := 'X';             -- reset_n
			synth_effects_ctrl_effects_ctrl_bus     : out std_logic_vector(17 downto 0);                    -- effects_ctrl_bus
			synth_sounds_ctrl_sound_ctrl_bus        : out std_logic_vector(87 downto 0);                    -- sound_ctrl_bus
			pio_keyboard_external_connection_export : in  std_logic_vector(7 downto 0)  := (others => 'X')  -- export
		);
	end component DE2_115_SOPC;

	u0 : component DE2_115_SOPC
		port map (
			clk_clk                                 => CONNECTED_TO_clk_clk,                                 --                              clk.clk
			pio_keys_external_connection_export     => CONNECTED_TO_pio_keys_external_connection_export,     --     pio_keys_external_connection.export
			pio_led_external_connection_export      => CONNECTED_TO_pio_led_external_connection_export,      --      pio_led_external_connection.export
			reset_reset_n                           => CONNECTED_TO_reset_reset_n,                           --                            reset.reset_n
			synth_effects_ctrl_effects_ctrl_bus     => CONNECTED_TO_synth_effects_ctrl_effects_ctrl_bus,     --               synth_effects_ctrl.effects_ctrl_bus
			synth_sounds_ctrl_sound_ctrl_bus        => CONNECTED_TO_synth_sounds_ctrl_sound_ctrl_bus,        --                synth_sounds_ctrl.sound_ctrl_bus
			pio_keyboard_external_connection_export => CONNECTED_TO_pio_keyboard_external_connection_export  -- pio_keyboard_external_connection.export
		);

