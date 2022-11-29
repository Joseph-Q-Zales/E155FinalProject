`timescale 10ns/1ns
/////////////////////////////////////////////
// makingNoise_tb
// Tests the internal functions that set the output of the pwm
/////////////////////////////////////////////

module makingNoise_tb();

    logic clk, start, pwm;
    logic[7:0] sd0, sd1, sd2, sd3, sd4, sd5;
    logic[35:0] clockSpeed;

    tune dut(clk, start, sd0, sd1, sd2, sd3, sd4, sd5, clockSpeed, pwm);

    always begin
        clk = 1; #5; clk = 0; #5;
    end

    assign sd0 = 5;
    assign sd1 = 10;
    assign sd2 = 8;
    assign sd3 = 15;
    assign sd4 = 5;
    assign sd5 = 5;
	
    assign clockSpeed = 20;

    initial begin
        #10;
        start = 1;
        #1000;

        $stop;
    end




endmodule
