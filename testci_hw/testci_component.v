module testci_component (
    clk,
    clk_en,
    reset,
    start,
    done,
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

    wire started;
    reg done;
    reg [31:0] tmp;

    assign started = started | start;
    assign result = (done) ? tmp : 0;

    always @ (posedge clk) begin
        if (reset) begin
            started <= 0;
            tmp     <= 0;
        end else begin
            if (clk_en) begin
                if (start) begin
                    tmp <= tmp << 1;
                end else if (started && !start) begin
                    tmp     <= tmp + 1;
                    started <= 0;
                end else begin
                    done <= 1;
                end
            end else begin
                tmp <= 0;
                done <= 0;
            end
        end
    end

endmodule // testci_component
