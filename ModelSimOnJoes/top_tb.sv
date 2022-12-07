/////////////////////////////////////////////
// top_tb
// Tests the top module
/////////////////////////////////////////////
module top_tb();
    logic clk, sck, sdi, ce, start, pwm, maingMusic;
    // logic [39:0] flattenedMCUout, newFlattenedMCUout;

    top dut(clk, sck, sdi, ce, !start, pwm, maingMusic);

    always begin
        clk = 1; #5; clk = 0; #5;
    end


    initial begin
        start = 1;
        #20;
        start = 0;
	
    end

endmodule