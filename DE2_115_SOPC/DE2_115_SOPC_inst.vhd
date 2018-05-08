	component DE2_115_SOPC is
		port (
			clk_clk                             : in  std_logic                     := 'X';             -- clk
			keyboard_ci_keycode_external        : in  std_logic_vector(7 downto 0)  := (others => 'X'); -- external
			keyboard_ci_ps2_read_external       : out std_logic;                                        -- external
			pio_keys_external_connection_export : in  std_logic_vector(17 downto 0) := (others => 'X'); -- export
			pio_led_external_connection_export  : out std_logic_vector(17 downto 0);                    -- export
			reset_reset_n                       : in  std_logic                     := 'X';             -- reset_n
			synth_effects_ctrl_bus              : out std_logic_vector(17 downto 0);                    -- bus
			synth_sound_ctrl_bus                : out std_logic_vector(87 downto 0)                     -- bus
		);
	end component DE2_115_SOPC;

	u0 : component DE2_115_SOPC
		port map (
			clk_clk                             => CONNECTED_TO_clk_clk,                             --                          clk.clk
			keyboard_ci_keycode_external        => CONNECTED_TO_keyboard_ci_keycode_external,        --          keyboard_ci_keycode.external
			keyboard_ci_ps2_read_external       => CONNECTED_TO_keyboard_ci_ps2_read_external,       --         keyboard_ci_ps2_read.external
			pio_keys_external_connection_export => CONNECTED_TO_pio_keys_external_connection_export, -- pio_keys_external_connection.export
			pio_led_external_connection_export  => CONNECTED_TO_pio_led_external_connection_export,  --  pio_led_external_connection.export
			reset_reset_n                       => CONNECTED_TO_reset_reset_n,                       --                        reset.reset_n
			synth_effects_ctrl_bus              => CONNECTED_TO_synth_effects_ctrl_bus,              --           synth_effects_ctrl.bus
			synth_sound_ctrl_bus                => CONNECTED_TO_synth_sound_ctrl_bus                 --             synth_sound_ctrl.bus
		);

