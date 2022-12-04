/////////////////////////////////////////////
// pwm_tb
// Tests the internal functions creates the pwm signal
/////////////////////////////////////////////

module pwm_tb();
    logic clk, en;
    logic pwm = 0;
    logic[31:0] freqerThreshold;

    assign freqerThreshold = 27272;
    //assign threshold = ((1/freq)*clockSpeed)/2 - 1;
 
    top dut(clk, 0, 0, 0, pwm);

	freqGenerator freqer(int_osc, 0'b1, 27272, song);

    always begin
        clk = 1; #5; clk = 0; #5;
    end

   // assign freq = 5;
   // assign clockSpeed = 30000;

endmodule
