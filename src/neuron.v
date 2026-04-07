module neuron (
    input clk,
    input in,
    output reg detect
);

reg s1 = 0;
reg s2 = 0;
reg s3 = 0;
reg s4 = 0;

reg prev = 0;

always @(posedge clk) begin
    detect <= 0;

    // 🔥 ONLY update when input changes (SPARSITY)
    if (in != prev) begin

        // Stage 1: first '1'
        if (in == 1 && !s1) begin
            s1 <= 1;
        end

        // Stage 2: second '1'
        else if (in == 1 && s1 && !s2) begin
            s2 <= 1;
        end

        // Stage 3: '0'
        else if (in == 0 && s2 && !s3) begin
            s3 <= 1;
        end

        // Stage 4: final '1'
        else if (in == 1 && s3 && !s4) begin
            s4 <= 1;
            detect <= 1;

            // reset after detection
            s1 <= 0;
            s2 <= 0;
            s3 <= 0;
            s4 <= 0;
        end

        // ❌ WRONG sequence → reset (leak-like behavior)
        else begin
            s1 <= 0;
            s2 <= 0;
            s3 <= 0;
            s4 <= 0;
        end
    end

    // update previous input
    prev <= in;
end

endmodule

`timescale 1ns/1ps

module testbench;

reg clk;
reg in;
wire detect;

neuron uut (
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
    repeat (300) begin
    in = ~in;
    #10;
	 end

    // pattern 1101
    in = 1; #10;
    in = 1; #10;
    in = 0; #10;
    in = 1; #10;

    // idle (IMPORTANT)
    repeat (50) begin
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
    $dumpfile("dump.vcd");
    $dumpvars(0, testbench);
end

endmodule