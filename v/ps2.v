module ps2(
    input            reset,
    input            clk,
    inout            PS2_CLK,
    inout            PS2_DAT,
    output           working,
    output reg [7:0] keycode
);

    /***************************************************************************
     *
     * Local variables for the PS2 interface
     *
     **************************************************************************/
    wire       clk2, ps2_clk_syn0, ps2_dat_syn0;
    reg        ps2_clk_syn1, ps2_clk_in, ps2_dat_syn1, ps2_dat_in;
    reg  [3:0] cnt;
    reg  [7:0] keycode_in;
    reg [15:0] clk_div;

    /***************************************************************************
     *
     * Structural code
     *
     **************************************************************************/

    /*
     * clk division, derive a 97.65625KHz clock from the 50MHz source;
     */
    always @ ( posedge clk ) begin
        clk_div <= clk_div+1;
    end
    assign clk2 = clk_div[8];

    /*
     * multi-clock region simple synchronization
     */
    assign ps2_clk_syn0 = PS2_CLK;
    assign ps2_dat_syn0 = PS2_DAT;
    always @ ( posedge clk2 ) begin
        ps2_clk_syn1 <= ps2_clk_syn0;
        ps2_clk_in   <= ps2_clk_syn1;
        ps2_dat_syn1 <= ps2_dat_syn0;
        ps2_dat_in   <= ps2_dat_syn1;
    end

    /*
     * Signal if the keyboard is currently sending data
     */
    assign working = (cnt != 0);

    /*
     * Serial input from keyboard.
     */
    always @ ( negedge ps2_clk_in ) begin
        cnt <= cnt + 1;
        if ( cnt == 9 ) begin
            keycode <= keycode_in;
        end else if ( cnt > 9 ) begin
            cnt <= 0;
        end else begin
        	case ( cnt[3:0] )
        		1 : keycode_in[0] <= ps2_dat_in;
        		2 : keycode_in[1] <= ps2_dat_in;
        		3 : keycode_in[2] <= ps2_dat_in;
        		4 : keycode_in[3] <= ps2_dat_in;
        		5 : keycode_in[4] <= ps2_dat_in;
        		6 : keycode_in[5] <= ps2_dat_in;
        		7 : keycode_in[6] <= ps2_dat_in;
        		8 : keycode_in[7] <= ps2_dat_in;
        	endcase
        end
    end
endmodule
