module trad (
    input clk,
    input in1, in2, in3, in4,
    output reg detect
);

reg [2:0] state;

parameter IDLE = 3'd0;
parameter S1   = 3'd1;
parameter S2   = 3'd2;
parameter S3   = 3'd3;
parameter S4   = 3'd4;

always @(posedge clk) begin
    detect <= 0;

    case (state)

        IDLE: begin
            if (in1)
                state <= S1;
            else
                state <= IDLE;
        end

        S1: begin
            if (in2)
                state <= S2;
            else if (in1)
                state <= S1;  // allow re-trigger
            else
                state <= IDLE;
        end

        S2: begin
            if (in3)
                state <= S3;
            else if (in1)
                state <= S1;
            else
                state <= IDLE;
        end

        S3: begin
            if (in4) begin
                state <= S4;
                detect <= 1;
            end
            else if (in1)
                state <= S1;
            else
                state <= IDLE;
        end

        S4: begin
            state <= IDLE; // reset after detection
        end

        default: state <= IDLE;

    endcase
end

endmodule

`timescale 1ns/1ps

module testbench_fsm;

reg clk;
reg in1, in2, in3, in4;
wire detect;

// Instantiate FSM
trad uut (
    .clk(clk),
    .in1(in1),
    .in2(in2),
    .in3(in3),
    .in4(in4),
    .detect(detect)
);


always #5 clk = ~clk;

initial begin
    clk = 0;
    in1 = 0; in2 = 0; in3 = 0; in4 = 0;

    // =========================
    // LONG IDLE (SPARSITY)
    // =========================
    repeat (5000) begin
        in1 = 0; in2 = 0; in3 = 0; in4 = 0;
        #10;
    end

    // =========================
    // RANDOM NOISE
    // =========================
    repeat (2000) begin
        in1 = $random % 2;
        in2 = $random % 2;
        in3 = $random % 2;
        in4 = $random % 2;
        #10;
    end

    // =========================
    // VALID SEQUENCE (RARE)
    // =========================
    in1 = 1; in2 = 0; in3 = 0; in4 = 0; #10;
    in1 = 0; in2 = 1; in3 = 0; in4 = 0; #10;
    in1 = 0; in2 = 0; in3 = 1; in4 = 0; #10;
    in1 = 0; in2 = 0; in3 = 0; in4 = 1; #10;

    // =========================
    // MORE IDLE
    // =========================
    repeat (5000) begin
        in1 = 0; in2 = 0; in3 = 0; in4 = 0;
        #10;
    end

    // =========================
    // ANOTHER VALID SEQUENCE
    // =========================
    in1 = 1; #10;
    in1 = 0; in2 = 1; #10;
    in2 = 0; in3 = 1; #10;
    in3 = 0; in4 = 1; #10;
    in4 = 0;

    // =========================
    // LIGHT NOISE (SPARSE)
    // =========================
    repeat (1000) begin
        in1 = ($random % 10 == 0); // very rare spikes
        in2 = ($random % 12 == 0);
        in3 = ($random % 15 == 0);
        in4 = ($random % 18 == 0);
        #10;
    end

    $finish;
end
//VCD DUMP
initial begin
    $dumpfile("fsm_dump.vcd");
    $dumpvars(0, testbench_fsm);
end

endmodule
