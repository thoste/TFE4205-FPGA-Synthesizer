module ps2_ci (
    input             clk,
    input             clk_en,
    input             reset,
    input             start,
    input       [7:0] keycode,
    output reg        ps2_read,
    output            done,
    output reg [31:0] result
);

    assign done = clk_en & ~start;
    assign ps2_read = done;

    parameter IDLE      = 4'h0;
    parameter READ      = 4'h1;
    parameter SHIFT     = 4'h2;
    parameter READ_MORE = 4'h3;
    parameter FINISH    = 4'h4;
    parameter DONE      = 4'h5;

    reg [3:0] state;
    reg [7:0] new_key;

    always @ ( clk ) begin
        if ( clk_en ) begin
            case ( state )
                IDLE:
                    if ( start )
                        state <= READ;
                READ:
                    result <= keycode;
                    ps2_read <= 1;
                    if ( keycode == 8'hf0 || keycode == 8'he0 ) begin
                        state <= SHIFT;
                    end else begin
                        state <= FINISH;
                    end
                SHIFT:
                    ps2_read <= 0;
                    result[31:8] <= result[23:0];
                    state <= READ_MORE;
                READ_MORE:
                    result[7:0] <= keycode;
                    if ( keycode == 8'hf0 || keycode == 8'he0 ) begin
                        ps2_read <= 1;
                        state <= SHIFT;
                    end else if ( keycode != 0 ) begin
                        ps2_read <= 1;
                        state <= FINISH;
                    end
                FINISH:
                    ps2_read <= 0;
                    done <= 1;
                    state <= DONE;
                DONE:
                    done <= 0;
                    state <= IDLE;
            endcase
        end else begin
            done <= 0;
            state <= IDLE;
        end
    end
endmodule // ps2_ci

    // OLD FSM IMPLEMENTATION
    // /***************************************************************************
    //  *
    //  * FSM states
    //  *
    //  **************************************************************************/
    //
    // parameter IDLE_DONE            = 8'h00;
    // parameter IDLE_STARTED         = 8'h01;
    // parameter IDLE_NEW             = 8'h02;
    // parameter WORKING_DONE         = 8'h10;
    // parameter WORKING_STARTED      = 8'h11;
    // parameter WORKING_NEW          = 8'h12;
    // parameter NEW_DONE             = 8'h20;
    // parameter NEW_STARTED          = 8'h21;
    // parameter NEW_NEW              = 8'h22;
    // parameter WORKING_MULT_DONE    = 8'h30;
    // parameter WORKING_MULT_STARTED = 8'h31;
    // parameter WORKING_MULT_NEW     = 8'h32;
    // parameter NEW_MULT_DONE        = 8'h40;
    // parameter NEW_MULT_STARTED     = 8'h41;
    // parameter NEW_MULT_NEW         = 8'h42;
    //
    // /***************************************************************************
    //  *
    //  * Internal variables
    //  *
    //  **************************************************************************/
    //
    // reg  [7:0] state;
    // wire [7:0] next_state;
    //
    // /*
    //  * Variables used for the PS2 interface
    //  */
    // wire       clk2, ps2_clk_syn0, ps2_dat_syn0;
    // reg        ps2_clk_syn1, ps2_clk_in, ps2_dat_syn1, ps2_dat_in;
    // reg  [3:0] cnt;
    // reg  [7:0] keycode_in;
    // reg [31:0] keycode_reg, cnt2;
    // reg [15:0] clk_div;
    //
    // /***************************************************************************
    //  *
    //  * FSM implementation
    //  *
    //  **************************************************************************/
    //
    // assign next_state = fsm_function(state, clk_en, start, done, cnt, keycode_in);
    //
    // always @ ( posedge clk ) begin
    //     if ( reset )
    //         state <= IDLE_DONE;
    //     else
    //         state <= next_state;
    // end
    //
    // function [7:0] fsm_function;
    //     input       state;
    //     input       clk_en;
    //     input       start;
    //     input       done;
    //     input [3:0] cnt;
    //     input [7:0] keycode_in;
    //
    //     case ( state )
    //         IDLE_DONE:
    //             if ( start )
    //                 fsm_function = IDLE_STARTED;
    //             else if ( cnt > 0 )
    //                 fsm_function = WORKING_DONE;
    //             else
    //                 fsm_function = IDLE_DONE;
    //         IDLE_STARTED:
    //             if ( done || !clk_en )
    //                 fsm_function = IDLE_DONE;
    //             else
    //                 fsm_function = IDLE_STARTED;
    //         IDLE_NEW:
    //             if ( start )
    //                 fsm_function = IDLE_STARTED;
    //             else if ( cnt > 0 )
    //                 fsm_function = WORKING_NEW;
    //             else
    //                 fsm_function = IDLE_NEW;
    //         WORKING_DONE:
    //             if ( start )
    //                 fsm_function = WORKING_STARTED;
    //             else if ( cnt >= 10 )
    //                 fsm_function = NEW_DONE;
    //             else
    //                 fsm_function = WORKING_DONE;
    //         WORKING_STARTED:
    //             if ( done || !clk_en )
    //                 fsm_function = WORKING_DONE;
    //             else
    //                 fsm_function = WORKING_STARTED;
    //         WORKING_NEW:
    //             if ( start )
    //                 fsm_function = WORKING_STARTED;
    //             else if ( cnt >= 10 )
    //                 fsm_function = NEW_NEW;
    //             else
    //                 fsm_function = WORKING_NEW;
    //         NEW_DONE:
    //             if ( start ) begin
    //                 fsm_function = NEW_STARTED;
    //             end else if ( cnt == 0 ) begin
    //                 if ( keycode_in == 8'hf0 || keycode_in == 8'he0 )
    //                     fsm_function = WORKING_MULT_DONE;
    //                 else
    //                     fsm_function = IDLE_NEW;
    //             end else begin
    //                 fsm_function = NEW_DONE;
    //             end
    //         NEW_STARTED:
    //             if ( done || !clk_en )
    //                 fsm_function = NEW_DONE;
    //             else
    //                 fsm_function = NEW_STARTED;
    //         NEW_NEW:
    //             if ( start ) begin
    //                 fsm_function = NEW_STARTED;
    //             end else if ( cnt == 0 ) begin
    //                 if ( keycode_in == 8'hf0 || keycode_in == 8'he0 )
    //                     fsm_function = WORKING_MULT_NEW;
    //                 else
    //                     fsm_function = IDLE_NEW;
    //             end else begin
    //                 fsm_function = NEW_NEW;
    //             end
    //         WORKING_MULT_DONE:
    //             if ( start )
    //                 fsm_function = WORKING_MULT_STARTED;
    //             else if ( cnt >= 10 )
    //                 fsm_function = NEW_MULT_DONE;
    //             else
    //                 fsm_function = WORKING_MULT_DONE;
    //         WORKING_MULT_STARTED:
    //             if ( done || !clk_en )
    //                 fsm_function = WORKING_MULT_DONE;
    //             else
    //                 fsm_function = WORKING_MULT_STARTED;
    //         WORKING_MULT_NEW:
    //             if ( start )
    //                 fsm_function = WORKING_MULT_STARTED;
    //             else if ( cnt >= 10 )
    //                 fsm_function = NEW_MULT_NEW;
    //             else
    //                 fsm_function = WORKING_MULT_NEW;
    //         NEW_MULT_DONE:
    //             if ( start ) begin
    //                 fsm_function = NEW_MULT_STARTED;
    //             end else if ( cnt == 0 ) begin
    //                 if ( keycode_in == 8'hf0 || keycode_in == 8'he0 )
    //                     fsm_function = WORKING_MULT_DONE;
    //                 else
    //                     fsm_function = IDLE_NEW;
    //             end else begin
    //                 fsm_function = NEW_MULT_DONE;
    //             end
    //         NEW_MULT_STARTED:
    //             if ( done || !clk_en )
    //                 fsm_function = NEW_MULT_DONE;
    //             else
    //                 fsm_function = NEW_MULT_STARTED;
    //         NEW_MULT_NEW:
    //             if ( start ) begin
    //                 fsm_function = NEW_MULT_STARTED;
    //             end else if ( cnt == 0 ) begin
    //                 if ( keycode_in == 8'hf0 || keycode_in == 8'he0 )
    //                     fsm_function = WORKING_MULT_NEW;
    //                 else
    //                     fsm_function = IDLE_NEW;
    //             end else begin
    //                 fsm_function = NEW_MULT_NEW;
    //             end
    //         default: fsm_function = IDLE_DONE;
    //     endcase
    // endfunction
    //
    // /*
    //  * Output logic
    //  */
    // always @ ( posedge clk ) begin
    //     if ( reset ) begin
    //         result <= 0;
    //     end else begin
    //         case ( state )
    //             IDLE_DONE: begin
    //                 result <= 0;
    //                 done <= 0;
    //             end
    //             IDLE_STARTED: begin
    //                 done <= 1;
    //             end
    //             IDLE_NEW: begin
    //                 result <= keycode_reg;
    //             end
    //             WORKING_DONE: begin
    //                 result <= 0;
    //                 done <= 0;
    //             end
    //             WORKING_STARTED: begin
    //                 done <= 1;
    //             end
    //             WORKING_NEW: begin
    //                 result <= keycode_reg;
    //             end
    //             NEW_DONE: begin
    //                 keycode_reg[31:8] <= 0;
    //                 keycode_reg[7:0] <= keycode_in;
    //                 result <= 0;
    //                 done <= 0;
    //             end
    //             NEW_STARTED: begin
    //                 done <= 1;
    //             end
    //             NEW_NEW: begin
    //                 keycode_reg[31:8] <= 0;
    //                 keycode_reg[7:0] <= keycode_in;
    //             end
    //             WORKING_MULT_DONE: begin
    //                 result <= 0;
    //                 done <= 0;
    //             end
    //             WORKING_MULT_STARTED: begin
    //                 done <= 1;
    //             end
    //             WORKING_MULT_NEW: begin
    //             end
    //             NEW_MULT_DONE: begin
    //                 keycode_reg[31:8] <= keycode_reg[23:0];
    //                 keycode_reg[7:0] <= keycode_in;
    //                 result <= 0;
    //                 done <= 0;
    //             end
    //             NEW_MULT_STARTED: begin
    //                 done <= 1;
    //             end
    //             NEW_MULT_NEW: begin
    //                 keycode_reg[31:8] <= keycode_reg[23:0];
    //                 keycode_reg[7:0] <= keycode_in;
    //             end
    //             default:
    //                 result <= 0;
    //         endcase
    //     end
    //     result <= keycode_reg;
    // end
    //
