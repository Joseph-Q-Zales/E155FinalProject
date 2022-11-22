/////////////////////////////////////////////
// top
//   Top level module with SPI interface and SPI core
/////////////////////////////////////////////

module top(input  logic clk, // for simulation purposes, delete and make an internal clock in the top module when done simulating
           input  logic sck, 
           input  logic sdi,
           output logic pwm);
                    
    logic [47:0] flattenedMCUout, newFlattenedMCUout;
	logic [7:0] sd0, sd1, sd2, sd3, sd4, sd5;
	logic [9:0] freq; // max frequency of 1023 with 10 bits
	logic [9:0] dur; // CHANGE, just for now doing 600
	logic song;
	logic int_osc;
	logic start;
	
	// Internal high-speed oscillator (instantiates the 24 MHz clock)
	HSOSC #(.CLKHF_DIV(2'b01))
		hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b0), .CLKHF(int_osc));
	
	// get signal data from MCU
    MCU_spi spi(sck, sdi, newFlattenedMCUout);
	
	always_ff @(posedge int_osc) begin
		if (newFlattenedMCUout != flattenedMCUout) begin
			start <= 1;
			flattenedMCUout <= newFlattenedMCUout;
			end
		else start <= 0;
	end
	
	// decoder for the spi data to get the specific signals
	make_signals makingSignals(flattenedMCUout, sd0, sd1, sd2, sd3, sd4, sd5);
	
	// FSM to create unique tune from signal data
	tune makeMusic(int_osc, start, sd0, sd1, sd2, sd3, sd4, sd5, song);
	
	assign pwm = song;
    
endmodule

/////////////////////////////////////////////
// MCU_spi
//   SPI interface.  Shifts  in the flattened MCU output
// 	 As only shifting in data, no need to wory about SDO
/////////////////////////////////////////////
module MCU_spi(input  logic sck, 
               input  logic sdi,
               output logic [47:0] newFlattenedMCUout);

    // SPI mode is equivalent to cpol = 0, cpha = 0 since data is sampled on first edge and the first
    // edge is a rising edge (clock going from low in the idle state to high).

	always_ff @(posedge sck) begin
		newFlattenedMCUout = {newFlattenedMCUout[46:0], sdi};
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
//    takes in the unique signals from the unpacked spi data and creates a unique song based on them
//    uses an FSM to cycle through unique notes with unique durations
//////
module tune(input logic int_osc,
				input logic start,
				input logic[7:0] sd0, 
				input logic[7:0] sd1,
				input logic[7:0] sd2,
				input logic[7:0] sd3,
				input logic[7:0] sd4,
				input logic[7:0] sd5,
				output logic song);
				
	logic done, en, rep;
	logic[1:0] threshold, counter;
	logic[7:0] dur;
	logic[9:0] freq;
	
	// state and next state definitions
	typedef enum logic[1:0] {idle, note1, note2, note3} statetype;
	statetype state, nextstate;
	
	// state register
	always_ff @(posedge int_osc) begin
		if(start) 	state <= note1;
		else 		state <= nextstate;
	end
	
	// assign repeat
	assign threshold = 5;//((sd0 + sd5) % 3);        		// TODO - make a new signal to assign to how many times we repeat (mod on the MCU side)
	assign rep = ~(counter == threshold);
	
	// instantiate dur and freq modules
	duration howLong(int_osc, dur, done);
	freqGenerator pitch(int_osc, en, freq, toneFreq);
	
	// only play music when we aren't in the idle state
	always_ff @(posedge int_osc) begin
		if (state == idle) en <= 0;
		else en <= 1;
	end
	
	always_ff @(posedge int_osc) begin
		if (state == note1) begin
			freq <= sd0;
			dur <= sd1;
		end
		else if (state == note2) begin
			freq <= sd2;
			dur <= sd3;
		end
		else if (state == note3) begin
			freq <= sd4;
			dur <= sd5;
			counter <= counter + 1;
		end
	end
	
	// nextstate logic
	always_comb
		case(state)
			note1: 	if(done)				nextstate = note2;
					else					nextstate = note1;
			note2: 	if(done)				nextstate = note3;
					else					nextstate = note2;
			note3: 	if(done && rep)			nextstate = note1;
					else if (done)			nextstate = idle;
					else					nextstate = note3;
			idle:	if(start)				nextstate = note1;
					else					nextstate = idle;
		endcase
	
	// output
	assign song = toneFreq;
				
endmodule

//////
//    takes in a unique duration value, outputs a flag when that duration has elapsed
/////
module duration(input logic int_osc,
				input logic[7:0] dur,
				output logic done);
				
	logic[31:0] counter, THRESHOLD;
	
	// calculate THRESHOLD based on dur
	assign THRESHOLD = dur*24000000 - 1;
	
	always_ff @(posedge int_osc) begin
		counter <= counter + 1;
	end
	
	assign done = (counter == THRESHOLD);
				
endmodule
				


//////
//    takes in a unique frequency value, creates a strobe clock at that frequency
/////
module freqGenerator(input logic int_osc, en,
				input logic[9:0] freq,
				output logic toneFreq);
	logic clkStrobe;
	logic[31:0] counter;
	logic[31:0] threshold;
	
	// threshold value is calculated from freq
	assign threshold = (1/freq)*24000000/2 - 1;
	
	// strobe counter (modified from E155 L02 on 9/1/22)
	always_ff @(posedge int_osc) begin
		if(clkStrobe) 	counter <= 0;
		else if (en) 	counter <= counter + 1;
		else 			counter <= 0;
	end
	
	// strobe generation (modified from E155 L02 on 9/1/22)
	always_ff @(posedge int_osc) begin
			clkStrobe <= (counter == threshold);
	end
	
	assign toneFreq = clkStrobe;
endmodule

