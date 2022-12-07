
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
    
    //assign freq0 = 3;
   // assign freq1 = 5; 
   // assign freq2 = 1;
   // assign freq3 = 2;
   // assign dur0 = 20;
    //assign dur1 = 15;
    //assign dur2 = 6;
    //assign dur3 = 15;
    //assign repThreshold = 2;
    
	
    assign clockSpeed = 1;

    initial begin
        #10;
     	freq0 = 3;
    	freq1 = 5; 
    	freq2 = 1;
    	freq3 = 2;
    	dur0 = 20;
    	dur1 = 15;
    	dur2 = 6;
    	dur3 = 15;
    	repThreshold = 2;
	#5
        start = 1;
        #10
	start = 0;
	#1500
	freq0 = 9;
    	freq1 = 12; 
    	freq2 = 4;
    	freq3 = 6;
    	dur0 = 25;
    	dur1 = 20;
    	dur2 = 7;
    	dur3 = 9;
    	repThreshold = 1;
	#5
	start = 1;
	#10 start = 0;
        //$stop;
    end


endmodule
