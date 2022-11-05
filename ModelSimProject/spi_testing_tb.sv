
`timescale 10ns/1ns
/////////////////////////////////////////////
// spi_testing_tb
// Tests spi between MCU and FPGA for unique 6 signals
/////////////////////////////////////////////

module testbench_aes_spi();
    logic clk, sck, sdi, pwm;

    logic [47:0] flattenedMCUout;
	logic [7:0] sd0, sd1, sd2, sd3, sd4, sd5;
	logic [9:0] freq; // max frequency of 1023 with 10 bits
	logic [9:0] dur; // CHANGE, just for now doing 600
	logic song;

    // Added delay
    logic delay;
    
    // device under test
    top dut(clk, sck, sdi, pwm);
    
    // test case
    initial begin   
// Test case from FIPS-197 Appendix A.1, B
        key       <= 128'h2B7E151628AED2A6ABF7158809CF4F3C;
        plaintext <= 128'h3243F6A8885A308D313198A2E0370734;
        expected  <= 128'h3925841D02DC09FBDC118597196A0B32;

    end
    
    // generate clock and load signals
    initial 
        forever begin
            clk = 1'b0; #5;
            clk = 1'b1; #5;
        end
     
    
	assign comb = {plaintext, key};
    // shift in test vectors, wait until done, and shift out result
    always @(posedge clk) begin
      if (i == 256) load = 1'b0;
      if (i<256) begin
        #1; sdi = comb[255-i];
        #1; sck = 1; #5; sck = 0;
        i = i + 1;
      end else if (done && delay) begin
        #100; // Delay to make sure that the answer is held correctly on the cyphertext before shifting out
        delay = 0;
      end else if (done && i < 384) begin
        #1; sck = 1; 
        #1; cyphertext[383-i] = sdo;
        #4; sck = 0;
        i = i + 1;
      end else if (i == 384) begin
            if (cyphertext == expected)
                $display("Testbench ran successfully");
            else $display("Error: cyphertext = %h, expected %h",
                cyphertext, expected);
            $stop();
      
      end
    end
    
endmodule