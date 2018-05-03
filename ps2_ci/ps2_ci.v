module ps2_ci (
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

endmodule // ps2_ci
