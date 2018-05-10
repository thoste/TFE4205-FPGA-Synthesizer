module ps2_ci (
    input             clk,
    input             clk_en,
    input             reset,
    input             start,
    input             working,
    input       [7:0] keycode,
    output reg        done,
    output reg [31:0] result
);

    /***************************************************************************
     *
     * Local signals
     *
     **************************************************************************/

    reg d_working, new_byte;
    reg [3:0] state;
    reg [31:0] shift;

    /***************************************************************************
     *
     * Structural coding
     *
     **************************************************************************/

    /*
     * Falling edge of the working signal indicates a new byte has been read.
     */
    always @ ( posedge clk ) begin
        d_working <= working;
        new_byte <= !working && d_working;
    end

    /***************************************************************************
     *
     * State machine.
     * The state machine makes sure that a key press is read only once and that
     * multi-byte keys are returned as a signle value. I.e. if 0xf0 and 0x1c are
     * received from the ps2 module the state machine returns 0xf01c.
     *
     **************************************************************************/

     /*
      * ZERO state is when zero is returned between keys.
      */
     parameter ZERO = 4'h0;

     /*
      * NEW state is when a new key has been received but not yet sent to the
      * processor.
      */
     parameter NEW = 4'h1;

     /*
      * SEND state is only entered after started has been high at some special
      * occations. It always sets done high and returns to ZERO.
      */
     parameter SEND = 4'h2;

     /*
      * INVALID state is when the state machine is receiving a multi-byte key
      * but haven't received all the bytes yet.
      */
     parameter INVALID = 4'h3;

     always @ ( posedge clk ) begin
        case ( state )
        ZERO: begin
            shift <= 0;
            result <= 0;
            done  <= start;
            if ( new_byte ) begin
                shift <= keycode;
                if ( keycode == 8'hf0 || keycode == 8'he0 ) begin
                    state <= INVALID;
                end else begin
                    state <= (start) ? SEND : NEW;
                    done  <= 0;
                end
            end
        end
        NEW: begin
            result <= shift;
            done   <= start;
            if ( new_byte ) begin
                shift <= keycode;
                if ( keycode == 8'hf0 || keycode == 8'he0 ) begin
                    state <= INVALID;
                end
            end else if ( start ) begin
                state <= ZERO;
                shift <= 0;
            end
        end
        SEND: begin
            state  <= ZERO;
            result <= shift;
            shift  <= 0;
            done   <= 1;
        end
        INVALID: begin
            result <= 0;
            done   <= start;
            if ( new_byte ) begin
                shift[31:8] <= shift[23:0];
                shift[7:0]  <= keycode;
                if ( keycode != 8'hf0 && keycode != 8'he0 ) begin
                    state <= (start) ? SEND : NEW;
                    done  <= 0;
                end
            end
        end
        default:
            state <= ZERO;
        endcase
     end
endmodule // ps2_ci
