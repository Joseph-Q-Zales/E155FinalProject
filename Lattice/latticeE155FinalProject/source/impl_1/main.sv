/////////////////////////////////////////////
// top
//   Top level module with SPI interface and SPI core
/////////////////////////////////////////////

module top(input  logic clk, // for simulation purposes, delete and make an internal clock in the top module when done simulating
           input  logic sck, 
           input  logic sdi,
		   input  logic ce,
           output logic pwm);
                    
    logic [39:0] flattenedMCUout, newFlattenedMCUout;
	logic [3:0] tone0, tone1, tone2, tone3, durMCU0, durMCU1, durMCU2, durMCU3;
	logic [7:0] repThreshold;
	logic [9:0] freq0, freq1, freq2, freq3, dur0, dur1, dur2, dur3; // max frequency of 1023 with 10 bits
	logic [9:0] dur; // CHANGE, just for now doing 600
	logic song;
	logic int_osc;
	logic start, makingMusic;
	
	logic[127:0] clockSpeed;

	// clockspeed is 2.4MHz
	assign clockSpeed = 2400000000;

	 // Internal high-speed oscillator (instantiates the 24 MHz clock)
	HSOSC #(.CLKHF_DIV(2'b01))
		hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b0), .CLKHF(int_osc));
	
	//assign int_osc = clk;
	
	// get signal data from MCU
    MCU_spi spi(sck, sdi, newFlattenedMCUout);
	
	always_ff @(negedge ce) begin
		if (!makingMusic) begin
			flattenedMCUout <= newFlattenedMCUout;
			start <= 1;
		end
	end
	
	// decoder for the spi data to get the specific signals
	make_signals makingSignals(flattenedMCUout, tone0, tone1, tone2, tone3, durMCU0, durMCU1, durMCU2, durMCU3, repThreshold);
	
	allTonesToFreq aT2F(tone0, tone1, tone2, tone3, freq0, freq1, freq2, freq3);
	
	allDurMCU2Durs ad2ds(durMCU0, durMCU1, durMCU2, durMCU3, dur0, dur1, dur2, dur3);
	
	// FSM to create unique tune from signal data
	tune makeMusic(int_osc, start, freq0, freq1, freq2, freq3, dur0, dur1, dur2, dur3, repThreshold, clockSpeed, makingMusic, song);
	
	assign pwm = song;
    
endmodule

/////////////////////////////////////////////
// MCU_spi
//   SPI interface.  Shifts  in the flattened MCU output
// 	 As only shifting in data, no need to wory about SDO
/////////////////////////////////////////////
module MCU_spi(input  logic sck, 
               input  logic sdi,
               output logic [39:0] newFlattenedMCUout);

    // SPI mode is equivalent to cpol = 0, cpha = 0 since data is sampled on first edge and the first
    // edge is a rising edge (clock going from low in the idle state to high).

	always_ff @(posedge sck) begin
		newFlattenedMCUout = {newFlattenedMCUout[38:0], sdi};
	end
    
endmodule

//////
//    module to unpack the spi data into the signal data variables
//////
module make_signals(input logic[39:0] flattenedMCUout,
					output logic[3:0] tone0,
					output logic[3:0] tone1,
					output logic[3:0] tone2,
					output logic[3:0] tone3,
					output logic[3:0] dur0,
					output logic[3:0] dur1,
					output logic[3:0] dur2,
					output logic[3:0] dur3,
					output logic[7:0] repThreshold);
	
	// match up signal variables to the crunched together version (variable 0 = msb)
	assign tone0 = flattenedMCUout[39:36];
	assign dur0  = flattenedMCUout[35:32];
	assign tone1 = flattenedMCUout[31:28];
	assign dur1  = flattenedMCUout[27:24];
	assign tone2 = flattenedMCUout[23:20];
	assign dur2  = flattenedMCUout[19:16];
	assign tone3 = flattenedMCUout[15:12];
	assign dur3  = flattenedMCUout[11:8];
	assign repThreshold   = flattenedMCUout[7:0];
	
endmodule

//////
//    module to decode all tones into frequencies
//////
module allTonesToFreq(input logic[3:0] tone0,
					input logic[3:0] tone1,
					input logic[3:0] tone2,
					input logic[3:0] tone3,
					output logic[9:0] freq0,
					output logic[9:0] freq1,
					output logic[9:0] freq2,
					output logic[9:0] freq3);
					
	toneToFreq t2F0(tone0, freq0);
	toneToFreq t2F1(tone1, freq1);
	toneToFreq t2F2(tone2, freq2);
	toneToFreq t2F3(tone3, freq3);
	
endmodule


//////
//    module to decode tone into frequency
//////
module toneToFreq(input logic[3:0] tone,
					output logic[9:0] freq);

	always_comb begin
		case(tone)
			0	:	freq = 220;	// A3
			1	:	freq = 247;	// B3
			2	:	freq = 262;	// C4
			3	: 	freq = 294;	// D4
			4	:	freq = 330;	// E4
			5	:	freq = 349;	// F4
			6 	:	freq = 392; // G4
			7	: 	freq = 440; // A4
			8	:	freq = 494;	// B4
			9	:	freq = 523;	// C5
			10	:	freq = 587;	// D5
			11	:	freq = 659;	// E5
			12	:	freq = 698; // F5
			13	:	freq = 784;	// G5
			14	:	freq = 880;	// A5
			15 	: 	freq = 262; // C4 (for the extra)
			default : freq = 262; // C4 (default)
		endcase
	end			
endmodule

//////
//    module to decode all durMCUs into durations (ms)
//////
module allDurMCU2Durs(input logic[3:0] durMCU0,
					input logic[3:0] durMCU1,
					input logic[3:0] durMCU2,
					input logic[3:0] durMCU3,
					output logic[9:0] dur0,
					output logic[9:0] dur1,
					output logic[9:0] dur2,
					output logic[9:0] dur3);
					
	durMCUtoDuration d2d0(durMCU0, dur0);
	durMCUtoDuration d2d1(durMCU1, dur1);
	durMCUtoDuration d2d2(durMCU2, dur2);
	durMCUtoDuration d2d3(durMCU3, dur3);
	
endmodule


//////
//    module to decode durD into duration in ms
//////
module durMCUtoDuration(input logic[3:0] durMCU,
					output logic[9:0] dur);

	always_comb begin
		case(durMCU)
			0	:	dur = 1000;	// whole note (1 second)
			1	:	dur = 1000;	// whole note (1 second)
			2	:	dur = 1000;	// whole note (1 second)
			3	: 	dur = 1000;	// whole note (1 second)
			4	:	dur = 1000;	// whole note (1 second)
			5	:	dur = 500;	// half note  (0.5 seconds)
			6 	:	dur = 500;  // half note  (0.5 seconds)
			7	: 	dur = 500;  // half note  (0.5 seconds)
			8	:	dur = 500;	// half note  (0.5 seconds)
			9	:	dur = 500;	// half note  (0.5 seconds)
			10	:	dur = 500;	// half note  (0.5 seconds)
			11	:	dur = 250;	// quarter note (0.25 seconds)
			12	:	dur = 250;  // quarter note (0.25 seconds)
			13	:	dur = 250;	// quarter note (0.25 seconds)
			14	:	dur = 250;	// quarter note (0.25 seconds)
			15 	: 	dur = 250;  // quarter note (0.25 seconds)
			default : dur = 250; // default: quarter note (0.25 seconds)
		endcase
	end			
endmodule

//////
//    takes in the unique signals from the unpacked spi data and creates a unique song based on them
//    uses an FSM to cycle through unique notes with unique durations
//////
module tune(input logic int_osc,
				input logic start,
				input logic[9:0] freq0,
				input logic[9:0] freq1,
				input logic[9:0] freq2,
				input logic[9:0] freq3,
				input logic[9:0] dur0,
				input logic[9:0] dur1,
				input logic[9:0] dur2,
				input logic[9:0] dur3,
				input logic[7:0] repThreshold,
				input logic[127:0] clockSpeed,
				output logic makingMusic,
				output logic song);
				
	logic done, en, rep;
	logic[1:0] threshold, counter;
	logic[7:0] dur;
	logic[9:0] freq;
	
	// assign repeat
	assign threshold = repThreshold[1:0];        		// TODO - make a new signal to assign to how many times we repeat (mod on the MCU side)
	assign rep = ~(counter == threshold);
	
		
	// instantiate dur and freq modules
	duration howLong(int_osc, dur, clockSpeed, done);
	freqGenerator pitch(int_osc, en, freq, clockSpeed, toneFreq);
	
	// state and next state definitions
	typedef enum logic[2:0] {idle, note0, note1, note2, note3, complete} statetype;
	statetype state, nextstate;
	
	// state register
	always_ff @(posedge int_osc) begin
		state <= nextstate;
	end
	//always_ff @(posedge int_osc) begin
	//	if(start) 	state <= note0;
	//	else 		state <= nextstate;
	//end
	
	
	// only play music when we aren't in the idle state
	always_ff @(posedge int_osc) begin
		if (state == idle) en <= 0;
		else en <= 1;
	end
	
	// if completed doorbell chime, flag makingMusic goes low
	// if completed doorbell chime, flag makingMusic goes low
	always_ff @(posedge int_osc) begin
		if (state == complete) makingMusic <= 0;
		else if (start) makingMusic <= 1;
	end
	
		
	// freq gets the frequency/duration of that note if its in that note's state
	always_ff @(posedge int_osc) begin
		if (state == note0) begin
			freq <= freq0;
			dur <= dur0;
		end
		else if (state == note1) begin
			freq <= freq1;
			dur <= dur1;
		end
		else if (state == note2) begin
			freq <= freq2;
			dur <= dur2;
		end
		else if (state == note3) begin
			freq <= freq3;
			dur <= dur3;
			counter <= counter + 1;
		end
	end
	
	// nextstate logic
	always_comb
		case(state)
			note0: 		if(done)				nextstate = note1;
						else					nextstate = note0;
			note1: 		if(done)				nextstate = note2;
						else					nextstate = note1;
			note2: 		if(done)				nextstate = note3;
						else					nextstate = note2;
			note3: 		if(done && rep)			nextstate = note0;
						else if (done)			nextstate = complete;
						else					nextstate = note3;
			complete:							nextstate = idle;
			idle:		if(start)				nextstate = note0;
						else					nextstate = idle;
			default: nextstate = idle;
		endcase
	
	// output
	assign song = toneFreq;
				
endmodule

//////
//    takes in a unique duration value in ms, outputs a flag when that duration has elapsed
/////
module duration(input logic int_osc,
				input logic[7:0] dur,
				input logic[127:0] clockSpeed,
				output logic done);
				
	logic[31:0] counter = 0;
	logic[31:0] THRESHOLD;
	logic clkStrobe;
 	
	
	// calculate THRESHOLD based on dur
	assign THRESHOLD = dur*clockSpeed - 1;
	

	// strobe counter (modified from E155 L02 on 9/1/22)
	always_ff @(posedge int_osc) begin
		if(counter == THRESHOLD) begin
			 	counter <= 0;
				clkStrobe <= 1;
		end
		else  			begin
				clkStrobe <= 0;
				counter <= counter + 1;
		end
		// clkStrobe <= (counter == THRESHOLD);
	end
	
	// strobe generation (modified from E155 L02 on 9/1/22)
	// always_ff @(posedge int_osc) begin
	// 		clkStrobe <= (counter == THRESHOLD);
	// end
	
	assign done = clkStrobe;

	// always_ff @(posedge int_osc) begin
	// 	counter <= counter + 1;
	// end
	 
	// assign done = (counter == THRESHOLD);


		
endmodule
				


//////
//    takes in a unique frequency value, creates a strobe clock at that frequency
/////
module freqGenerator(input logic int_osc, en,
				input logic[9:0] freq,
				input logic[127:0] clockSpeed,
				output logic toneFreq);
	logic clkStrobe;
	logic[31:0] counter;
	logic[31:0] threshold;
	
	// threshold value is calculated from freq
	assign threshold = ((1/freq)*clockSpeed)/2 - 1;
	
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

