	component clocks is
		port (
			clk_0_clk              : in  std_logic := 'X'; -- clk
			reset_0_reset_n        : in  std_logic := 'X'; -- reset_n
			reset_1_reset_n        : in  std_logic := 'X'; -- reset_n
			clk_1_clk              : in  std_logic := 'X'; -- clk
			clock_27_clk_clk       : out std_logic;        -- clk
			clock_27_reset_reset_n : out std_logic;        -- reset_n
			clock_25_clk           : out std_logic;        -- clk
			clock_25_reset_reset_n : out std_logic         -- reset_n
		);
	end component clocks;

	u0 : component clocks
		port map (
			clk_0_clk              => CONNECTED_TO_clk_0_clk,              --          clk_0.clk
			reset_0_reset_n        => CONNECTED_TO_reset_0_reset_n,        --        reset_0.reset_n
			reset_1_reset_n        => CONNECTED_TO_reset_1_reset_n,        --        reset_1.reset_n
			clk_1_clk              => CONNECTED_TO_clk_1_clk,              --          clk_1.clk
			clock_27_clk_clk       => CONNECTED_TO_clock_27_clk_clk,       --   clock_27_clk.clk
			clock_27_reset_reset_n => CONNECTED_TO_clock_27_reset_reset_n, -- clock_27_reset.reset_n
			clock_25_clk           => CONNECTED_TO_clock_25_clk,           --       clock_25.clk
			clock_25_reset_reset_n => CONNECTED_TO_clock_25_reset_reset_n  -- clock_25_reset.reset_n
		);

