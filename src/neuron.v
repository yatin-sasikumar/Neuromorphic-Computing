module neuron (
    input in1, in2, in3, in4,
    output reg detect
);

// neuron states (memory)
reg s1 = 0;
reg s2 = 0;
reg s3 = 0;


always @(in1 or in2 or in3 or in4) begin
    detect = 0;

    // Stage 1
    if (in1) begin
        s1 = 1;
    end

    // Stage 2
    if (in2 && s1) begin
        s2 = 1;
    end

    // Stage 3
    if (in3 && s2) begin
        s3 = 1;
    end

    // Final detection
    if (in4 && s3) begin
        detect = 1;

        // reset after detection
        s1 = 0;
        s2 = 0;
        s3 = 0;
    end

  
    if (in2 && !s1) begin
        s2 = 0;
        s3 = 0;
    end

    if (in3 && !s2) begin
        s3 = 0;
    end
end

endmodule

`timescale 1ns/1ps

module testbench_snn;


reg in1, in2, in3, in4;
wire detect;

// Instantiate FSM
neuron uut (
    
    .in1(in1),
    .in2(in2),
    .in3(in3),
    .in4(in4),
    .detect(detect)
);
initial begin
  
    in1 = 0; in2 = 0; in3 = 0; in4 = 0;

    // =========================
    //  LONG IDLE (SPARSITY)
    // =========================
    repeat (5000) begin
        in1 = 0; in2 = 0; in3 = 0; in4 = 0;
        #10;
    end

    // =========================
    //  RANDOM NOISE
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
    //  MORE IDLE
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

// VCD DUMP 
initial begin
    $dumpfile("snn_dump.vcd");
    $dumpvars(0, testbench_snn);
end

endmodule
