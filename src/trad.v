module trad (
    input clk,
    input in,
    output reg detect
);

reg [2:0] state;

parameter S0 = 3'd0;
parameter S1 = 3'd1;
parameter S2 = 3'd2;
parameter S3 = 3'd3;
parameter S4 = 3'd4;

always @(posedge clk) begin
    detect <= 0;

    case (state)

        S0: begin
            if (in == 1)
                state <= S1;
            else
                state <= S0;
        end

        S1: begin
            if (in == 1)
                state <= S2;
            else
                state <= S0;
        end

        S2: begin
            if (in == 0)
                state <= S3;
            else
                state <= S2; // stay if 1
        end

        S3: begin
            if (in == 1) begin
                state <= S4;
                detect <= 1;
            end
            else
                state <= S0;
        end

        S4: begin
            state <= S0; // reset after detection
        end

        default: state <= S0;

    endcase
end

endmodule

`timescale 1ns/1ps

module testbench_1;

reg clk;
reg in;
wire detect;

trad uut (
    .clk(clk),
    .in(in),
    .detect(detect)
);

// clock
always #5 clk = ~clk;

initial begin
    clk = 0;
    in = 0;

    // noise
    repeat (3000) begin
    in = ~in;
    #10;
	 end

    // pattern 1101
    in = 1; #10;
    in = 1; #10;
    in = 0; #10;
    in = 1; #10;

    // idle (IMPORTANT)
    repeat (5000) begin
        in = 0;
        #10;
    end

    // more patterns
    in = 1; #10;
    in = 1; #10;
    in = 0; #10;
    in = 1; #10;

    // more noise
    repeat (100) begin
        in = $random % 2;
        #10;
    end

    $finish;
end

// VCD
initial begin
    $dumpfile("dump1.vcd");
    $dumpvars(0, testbench_1);
end

endmodule