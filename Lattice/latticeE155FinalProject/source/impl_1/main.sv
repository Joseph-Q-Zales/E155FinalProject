/////////////////////////////////////////////
// top
//   Top level module with SPI interface and SPI core
/////////////////////////////////////////////

module top(input  logic clk, // for simulation purposes, delete and make an internal clock in the top module when done simulating
           input  logic sck, 
           input  logic sdi,
           output logic pwm);
                    
    logic [47:0] flattenedMCUout;
	logic [7:0] sd0, sd1, sd2, sd3, sd4, sd5;
	logic [9:0] freq; // max frequency of 1023 with 10 bits
	logic [9:0] dur; // CHANGE, just for now doing 600
	logic song;
	
	// get signal data from MCU
    MCU_spi spi(sck, sdi, flattenedMCUout);
	
	// decoder for the spi data to get the specific signals
	make_signals makingSignals(flattenedMCUout, sd0, sd1, sd2, sd3, sd4, sd5);
	
	// generate the unique freq and dur given the signals
	uniqueTune tune(sd0, sd1, sd2, sd3, sd4, sd5, freq, dur);
	
	// output pwm based on frequency and duration
	pwmDriver pwmer(freq, dur, song); // need to put in a continous flip flop or something? make sure that the song output keeps playing? (see comment in module)
	
	assign pwm = song;
    
endmodule

/////////////////////////////////////////////
// MCU_spi
//   SPI interface.  Shifts  in the flattened MCU output
// 	 As only shifting in data, no need to wory about SDO
/////////////////////////////////////////////
module MCU_spi(input  logic sck, 
               input  logic sdi,
               output logic [47:0] flattenedMCUout);

    // SPI mode is equivalent to cpol = 0, cpha = 0 since data is sampled on first edge and the first
    // edge is a rising edge (clock going from low in the idle state to high).

	always_ff @(posedge sck) begin
		flattenedMCUout = {flattenedMCUout[46:0], sdi};
	end
    
endmodule

//////
//    module to unpack the spi data into the signal data variables
//////
module make_signals(input logic[47:0] flattenedMCUout,
					output logic[7:0] sd0,
					output logic[7:0] sd1,
					output logic[7:0] sd2,
					output logic[7:0] sd3,
					output logic[7:0] sd4,
					output logic[7:0] sd5);
	
	// match up signal variables to the crunched together version (variable 0 = msb)
	assign sd0 = flattenedMCUout[47:40];
	assign sd1 = flattenedMCUout[39:32];
	assign sd2 = flattenedMCUout[31:24];
	assign sd3 = flattenedMCUout[23:16];
	assign sd4 = flattenedMCUout[15:8];
	assign sd5 = flattenedMCUout[7:0];
					
endmodule

//////
//    takes in the unique signals from the unpacked spi data and creates a unique frequency and duration based on them
//////
module uniqueTune(input logic[7:0] sd0, 
				input logic[7:0] sd1,
				input logic[7:0] sd2,
				input logic[7:0] sd3,
				input logic[7:0] sd4,
				input logic[7:0] sd5,
				output logic[9:0] freq,
				output logic[9:0] dur);
	
	// PERFORM UNIQUE CALCULATIONS HERE TO CALCULATE THESE VALUES BASED ON THE GIVEN SIGNAL VARIABLES
	assign freq = 10'b0101010101;
	assign dur = 10'b1010101010;
				
endmodule

//////
//    takes in the unique frequency and song duration and creates the song based on it!
// only outputs one bit, but does so continously ---- HOW TO IMPLEMENT THIS?
/////
module pwmDriver(input logic[9:0] freq,
				input logic[9:0] dur,
				output logic song);
				
	// MAKE PWM DRIVER BASED ON FREQ AND DUR
	assign song = 1;
				
endmodule

