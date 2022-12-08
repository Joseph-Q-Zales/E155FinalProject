`timescale 1ps/1ps
/////////////////////////////////////////////
// top_tb
// Tests the top module
/////////////////////////////////////////////
module top_tb();
    logic clk, ce, nreset, start, pwm, maingMusic;
    logic [39:0] newFlattenedMCUout;


    SimTop dut(clk, nreset, newFlattenedMCUout, ce, pwm, maingMusic);

    always begin
        clk = 1; #1; clk = 0; #1;
    end


    initial begin
	#10;
	nreset = 1;
	#10;
	nreset = 0;
	#10;
	ce = 1;
	#5;
	newFlattenedMCUout = 0'h42B46D8012;
	#15;
	ce = 0;
	#20;
	#100000;
	ce = 1;
	#10;
	newFlattenedMCUout = 0'h42B46D8012;
	#10
	ce = 0;
	#1000;
	
    end

endmodule