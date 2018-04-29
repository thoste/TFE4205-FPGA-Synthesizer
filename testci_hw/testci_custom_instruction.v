module testci_custom_instruction (
    clk,
    clk_en,
    reset,
    start,
    dataa,
    done,
    result
);

    input clk;
    input clk_en;
    input reset;
    input start;
    input [31:0] dataa;
    output done;
    output [31:0] result;

    testci_component cmp(
        .clk(clk),
        .clk_en(clk_en),
        .reset(reset),
        .start(start),
        .done(done),
        .dataa(dataa),
        .done(done),
        .result(result)
    );

endmodule // testci_custom_instruction
