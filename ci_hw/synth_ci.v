module synth_ci (
    input         clk,
    input         clk_en,
    input         reset,
    input         start,
    input   [1:0] opcode, // n
    input  [31:0] data,   // dataa
    output        done,
    output [87:0] sounds_ctrl,
    output [17:0] effects_ctrl
);

    assign done = clk_en & ~start;

    localparam key_on     = 2'b00;
    localparam key_off    = 2'b01;
    localparam effect_on  = 2'b10;
    localparam effect_off = 2'b11;

    reg [87:0] cur_sounds;
    reg [17:0] cur_effects;

    always @ ( posedge clk or posedge reset ) begin
        if (reset) begin
            // Nothing...
        end else if (clk_en) begin
            if (start) begin
                case (opcode)
                key_on: begin
                    cur_sounds[data] <= 1'b1;
                end
                key_off: begin
                    cur_sounds[data] <= 1'b0;
                end
                effect_on: begin
                    cur_effects[data] <= 1'b1;
                end
                effect_off: begin
                    cur_effects[data] <= 1'b0;
                end
                endcase
            end
        end
    end

    assign sounds_ctrl  = cur_sounds;
    assign effects_ctrl = cur_effects;

endmodule // synth_ci
