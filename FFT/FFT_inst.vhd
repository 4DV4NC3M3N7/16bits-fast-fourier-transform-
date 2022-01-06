	component FFT is
		port (
			clk_clk : in std_logic := 'X'  -- clk
		);
	end component FFT;

	u0 : component FFT
		port map (
			clk_clk => CONNECTED_TO_clk_clk  -- clk.clk
		);

