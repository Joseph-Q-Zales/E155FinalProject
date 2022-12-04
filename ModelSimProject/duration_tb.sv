//`timescale 10ns/1ns
/////////////////////////////////////////////
// makingNoise_tb
// Tests the internal functions that set the output of the pwm
/////////////////////////////////////////////

module duration_tb();

    logic clk, done;
    logic[7:0] dur;
    logic[127:0] clockSpeed;

    assign clockSpeed = 10;

    //assign dur = 10;

    duration dut(clk, dur, clockSpeed, done);

    always begin
        clk = 1; #5; clk = 0; #5;
    end

     initial begin   
 	dur = 10;
	end


endmodule
