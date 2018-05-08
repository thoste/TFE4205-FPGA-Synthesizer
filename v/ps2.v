module ps2(
    input            reset,
    input            clk,  //clock source;
    input            read,
    inout            PS2_CLK,  //ps2_clock signal inout;
    inout            PS2_DAT,  //ps2_data  signal inout;
    output reg [7:0] keycode
);

    /*
     * Variables used for the PS2 interface
     */
    wire       clk2, ps2_clk_syn0, ps2_dat_syn0;
    reg        ps2_clk_syn1, ps2_clk_in, ps2_dat_syn1, ps2_dat_in;
    reg        new_byte;
    reg  [3:0] cnt;
    reg  [7:0] keycode_in;
    reg  [7:0] keycode_reg;
    reg [15:0] clk_div;

    /***************************************************************************
     *
     * FSM implementation
     *
     **************************************************************************/

    always @ ( posedge clk ) begin
        if ( new_byte ) begin
            keycode <= keycode_reg;
        end else begin
            keycode <= 0;
        end
    end

    /*
     * Output logic
     */
    always @ ( cnt or read ) begin
        if ( read ) begin
            new_byte = 0;
        end else if ( cnt > 9 ) begin
            new_byte = 1;
        end
    end

    /***************************************************************************
     *
     * PS2 handling
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
     * Serial input from keyboard.
     */
    always @ ( negedge ps2_clk_in ) begin
        cnt <= cnt + 1;
        if ( cnt == 9 ) begin
            keycode_reg <= keycode_in;
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

    // function [7:0] fsm_function;
    //     input       state;
    //     input       start;
    //     input       done;
    //     input [3:0] cnt;
    //     input [7:0] keycode_in;
    //
    //     case ( state )
    //         IDLE:
    //             if ( cnt > 0 ) begin
    //                 if ( start )
    //                     fsm_function = WORKING_STARTED;
    //                 else
    //                     fsm_function = WORKING;
    //             end else if ( start ) begin
    //                 fsm_function = SEND;
    //             end else begin
    //                 fsm_function = IDLE;
    //             end
    //         SEND:
    //             if ( done )
    //                 fsm_function = DONE;
    //             else
    //                 fsm_function = SEND;
    //         DONE:
    //             if ( !done )
    //                 fsm_function = IDLE;
    //             else
    //                 fsm_function = DONE;
    //         WORKING:
    //             if ( cnt >= 9 ) begin
    //                 if ( start )
    //                     fsm_function = NEW_STARTED;
    //                 else
    //                     fsm_function = NEW;
    //             end else if ( start ) begin
    //                 fsm_function = WORKING_STARTED;
    //             end else begin
    //                 fsm_function = WORKING;
    //             end
    //         WORKING_STARTED:
    //             if ( cnt >= 9 )
    //                 fsm_function = NEW_STARTED;
    //             else
    //                 fsm_function = WORKING_STARTED;
    //         NEW:
    //             if ( !cnt ) begin
    //                 if ( keycode_in == 8'hf0 || keycode_in == 8'he0 ) begin
    //                     if ( start )
    //                         fsm_function = WORKING_MULT_STARTED;
    //                     else
    //                         fsm_function = WORKING_MULT;
    //                 end else begin
    //                     if ( start )
    //                         fsm_function = NEW_RESULT_STARTED;
    //                     else
    //                         fsm_function = NEW_RESULT;
    //                 end
    //             end else if ( start ) begin
    //                 fsm_function = NEW_STARTED;
    //             end else begin
    //                 fsm_function = NEW;
    //             end
    //         NEW_STARTED:
    //             if ( !cnt ) begin
    //                 if ( keycode_in == 8'hf0 || keycode_in == 8'he0 ) begin
    //                     fsm_function = WORKING_MULT_STARTED;
    //                 end else begin
    //                     fsm_function = NEW_RESULT_STARTED;
    //                 end
    //             end else begin
    //                 fsm_function = NEW_STARTED;
    //             end
    //         WORKING_MULT:
    //             if ( cnt >= 10 ) begin
    //                 if ( start )
    //                     fsm_function = NEW_MULT_STARTED;
    //                 else
    //                     fsm_function = NEW_MULT;
    //             end else begin
    //                 fsm_function = WORKING_MULT;
    //             end
    //         WORKING_MULT_STARTED:
    //             if ( cnt >= 10 )
    //                 fsm_function = NEW_MULT_STARTED;
    //             else
    //                 fsm_function = WORKING_MULT_STARTED;
    //         NEW_MULT:
    //             if ( !cnt ) begin
    //                 if ( keycode_in == 8'hf0 || keycode_in == 8'he0 ) begin
    //                     if ( start )
    //                         fsm_function = WORKING_MULT_STARTED;
    //                     else
    //                         fsm_function = WORKING_MULT;
    //                 end else begin
    //                     if ( start )
    //                         fsm_function = NEW_RESULT_STARTED;
    //                     else
    //                         fsm_function = NEW_RESULT;
    //                 end
    //             end else if ( start ) begin
    //                 fsm_function = NEW_MULT_STARTED;
    //             end else begin
    //                 fsm_function = NEW_MULT;
    //             end
    //         NEW_MULT_STARTED:
    //             if ( !cnt ) begin
    //                 if ( keycode_in == 8'hf0 || keycode_in == 8'he0 ) begin
    //                     fsm_function = WORKING_MULT_STARTED;
    //                 end else begin
    //                     fsm_function = NEW_RESULT_STARTED;
    //                 end
    //             end else begin
    //                 fsm_function = NEW_MULT_STARTED;
    //             end
    //         NEW_RESULT:
    //             if ( start )
    //                 fsm_function = SEND;
    //             else
    //                 fsm_function = IDLE;
    //         NEW_RESULT_STARTED:
    //             fsm_function = SEND;
    //         default: fsm_function = IDLE;
    //     endcase
    // endfunction
    //
    // /*
    //  * Output logic
    //  */
    // always @ ( posedge clk ) begin
    //         case ( state )
    //             // IDLE:
    //             SEND: begin
    //                 done <= 1;
    //             end
    //             DONE: begin
    //                 done <= 0;
    //                 keycode <= 0;
    //             end
    //             WORKING:
    //                 cnt1 <= cnt1 + 1;
    //             WORKING_STARTED:
    //                 cnt2 <= cnt2 + 1;
    //             NEW: begin
    //                 cnt3 <= cnt3 + 1;
    //                 keycode_reg[31:8] <= 0;
    //                 keycode_reg[7:0]  <= keycode_in;
    //             end
    //             NEW_STARTED: begin
    //                 cnt4 <= cnt4 + 1;
    //                 keycode_reg[31:8] <= 0;
    //                 keycode_reg[7:0]  <= keycode_in;
    //             end
    //             // WORKING_MULT:
    //             // WORKING_MULT_STARTED:
    //             NEW_MULT: begin
    //                 keycode_reg[31:8] <= keycode_reg[23:0];
    //                 keycode_reg[7:0]  <= keycode_in;
    //             end
    //             NEW_MULT_STARTED: begin
    //                 keycode_reg[31:8] <= keycode_reg[23:0];
    //                 keycode_reg[7:0]  <= keycode_in;
    //             end
    //             NEW_RESULT: begin
    //                 keycode <= keycode_reg;
    //             end
    //             NEW_RESULT_STARTED: begin
    //                 keycode <= keycode_reg;
    //             end
    //         endcase
    //     keycode <= {cnt4, cnt3, cnt2, cnt1};
    // end
