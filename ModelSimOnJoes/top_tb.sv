/////////////////////////////////////////////
// top_tb
// Tests the top module
/////////////////////////////////////////////
module top_tb();
    logic clk, ce, nreset, start, pwm, maingMusic;
    logic [39:0] newFlattenedMCUout;


    SimTop dut(clk, nreset, newFlattenedMCUout, ce, pwm, maingMusic);

    always begin
        clk = 1; #5; clk = 0; #5;
    end


    initial begin
	#10;
	nreset = 1;
	#10;
	nreset = 0;
	#10;
	ce = 1;
	#5;
	newFlattenedMCUout = 0'h0123456789;
	#15;
	ce = 0;
	#20;
	#1000;
	nreset = 1;
	#15;
	nreset = 0;
	#10;
	
    end

endmodule