
/////////////////////////////////////////////
// makingNoise_tb
// Tests the internal functions that set the output of the pwm
/////////////////////////////////////////////

module makingNoise_tb();

    logic clk, start, pwm, makingMusic;
    logic[31:0] freq0, freq1, freq2, freq3, dur0, dur1, dur2, dur3;
    logic[7:0] repThreshold;

    tune dut(clk, start, freq0, freq1, freq2, freq3, dur0, dur1, dur2, dur3, repThreshold, makingMusic, pwm);

    always begin
        clk = 1; #5; clk = 0; #5;
    end
    
    assign freq0 = 3;
    assign freq1 = 5; 
    assign freq2 = 1;
    assign freq3 = 2;
    assign dur0 = 20;
    assign dur1 = 15;
    assign dur2 = 6;
    assign dur3 = 15;
    assign repThreshold = 2;
    
	
    assign clockSpeed = 1;

    initial begin
        #10;
        start = 1;
        #1000;

        //$stop;
    end




endmodule
