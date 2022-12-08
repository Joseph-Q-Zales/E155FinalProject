///////////////////////////////////////////////////////////////////////////////////
// main.sv																	     //
// FPGA code to create a PWM at a frequency and duration determined by the MCU   //
// Creates the "doorbell" sounds												 //					
// Date: 12/8/2022																 //
// Authors: Ava Fascetti & Joe Zales											 //
// Emails: afascetti@hmc.edu, jzales@hmc.edu									 //
///////////////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////
// top
//   Top level module with SPI interface and SPI core
/////////////////////////////////////////////
module top(input  logic reset, // for simulation purposes, delete and make an internal clock in the top module when done simulating
           input  logic sck, 
           input  logic sdi,
		   input  logic ce,
           output logic pwm,
		   output logic makingMusic);
    
	// internal signals
    logic [39:0] flattenedMCUout, newFlattenedMCUout;
	logic [3:0] tone0, tone1, tone2, tone3, durMCU0, durMCU1, durMCU2, durMCU3;
	logic [7:0] repThreshold;
	logic [31:0] freqThreshold0, freqThreshold1, freqThreshold2, freqThreshold3;	
	logic [31:0] durThresh0, durThresh1, durThresh2, durThresh3;
	logic song, int_osc, start;

	 // Internal high-speed oscillator (instantiates the 24 MHz clock)
	HSOSC #(.CLKHF_DIV(2'b01))
		hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));
		
	// get signal data from MCU
    MCU_spi spi(sck, sdi, newFlattenedMCUout);
	
	// turns on enables based on the SPI's chip enable and whether or not the doorbell is ringing
	enables enabler(int_osc, ce, makingMusic, newFlattenedMCUout, start, flattenedMCUout);
	
	// decoder for the spi data to get the specific signals
	make_signals makingSignals(flattenedMCUout, tone0, tone1, tone2, tone3, durMCU0, durMCU1, durMCU2, durMCU3, repThreshold);
	
	//allTonesToFreq aT2F(tone0, tone1, tone2, tone3, freq0, freq1, freq2, freq3);
	allTonesToFreqThreshold aT2FT(tone0, tone1, tone2, tone3, freqThreshold0, freqThreshold1, freqThreshold2, freqThreshold3);
	
	//allDurMCU2Durs ad2ds(durMCU0, durMCU1, durMCU2, durMCU3, dur0, dur1, dur2, dur3);
	allDurMCU2DursThresh aD2DT(durMCU0, durMCU1, durMCU2, durMCU3, durThresh0, durThresh1, durThresh2, durThresh3);
	
	 // FSM to create unique tune from signal data
	 tune tuner(int_osc, reset, start, freqThreshold0, freqThreshold1, freqThreshold2, freqThreshold3,  durThresh0, durThresh1, durThresh2, durThresh3, repThreshold, makingMusic, song);

	// song output
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
//    module to decode all tones into the threshokds required by the frequency strobe clock
//////
module allTonesToFreqThreshold(input logic[3:0] tone0,
					input logic[3:0] tone1,
					input logic[3:0] tone2,
					input logic[3:0] tone3,
					output logic[31:0] freqThreshold0,
					output logic[31:0] freqThreshold1,
					output logic[31:0] freqThreshold2,
					output logic[31:0] freqThreshold3);
	
	// converts tones to the known frequency threshold				
	toneToFreqThreshold t2F0(tone0, freqThreshold0);
	toneToFreqThreshold t2F1(tone1, freqThreshold1);
	toneToFreqThreshold t2F2(tone2, freqThreshold2);
	toneToFreqThreshold t2F3(tone3, freqThreshold3);
	
endmodule

//////
//    module to decode a tone into the threshold required for the strobe clock in the pwm frequency generator
//////
module toneToFreqThreshold(input logic[3:0] tone,
					output logic[31:0] threshold);

	always_comb begin
		case(tone)
			0	:	threshold = 54544;	// A3
			1	:	threshold = 48582;	// B3
			2	:	threshold = 45801;	// C4
			3	: 	threshold = 40815;	// D4
			4	:	threshold = 36363;	// E4
			5	:	threshold = 34383;	// F4
			6 	:	threshold = 30611;  // G4
			7	: 	threshold = 27272;  // A4
			8	:	threshold = 24290;	// B4
			9	:	threshold = 22944;	// C5
			10	:	threshold = 20442;	// D5
			11	:	threshold = 18208;	// E5
			12	:	threshold = 17191;  // F5
			13	:	threshold = 15305;	// G5
			14	:	threshold = 13635;	// A5
			15 	: 	threshold = 27272;  // A4 (for the extra)
			default : threshold = 2726; // A4 (default)
		endcase
	end			
endmodule

//////
//    module to decode all durMCUs into durations thresholds required by the duration module's strobe clock
//////
module allDurMCU2DursThresh(input logic[3:0] durMCU0,
					input logic[3:0] durMCU1,
					input logic[3:0] durMCU2,
					input logic[3:0] durMCU3,
					output logic[31:0] durThresh0,
					output logic[31:0] durThresh1,
					output logic[31:0] durThresh2,
					output logic[31:0]durThresh3);
					
	durMCUtoDurationThreshold d2d0(durMCU0, durThresh0);
	durMCUtoDurationThreshold d2d1(durMCU1, durThresh1);
	durMCUtoDurationThreshold d2d2(durMCU2, durThresh2);
	durMCUtoDurationThreshold d2d3(durMCU3, durThresh3);
	
endmodule


//////
//    module to decode durD into duration thresholds the threshold required by the duration module's strobe clock
//////
module durMCUtoDurationThreshold(input logic[3:0] durMCU,
					output logic[31:0] durThresh);

	always_comb begin
		case(durMCU)
			0	:	durThresh = 24000000;	// whole note (1 second)
			1	:	durThresh = 24000000;	// whole note (1 second)
			2	:	durThresh = 24000000;	// whole note (1 second)
			3	: 	durThresh = 24000000;	// whole note (1 second)
			4	:	durThresh = 24000000;	// whole note (1 second)
			5	:	durThresh = 12000000;	// half note  (0.5 seconds)
			6 	:	durThresh = 12000000;  // half note  (0.5 seconds)
			7	: 	durThresh = 12000000;  // half note  (0.5 seconds)
			8	:	durThresh = 12000000;	// half note  (0.5 seconds)
			9	:	durThresh = 12000000;	// half note  (0.5 seconds)
			10	:	durThresh = 12000000;	// half note  (0.5 seconds)
			11	:	durThresh = 6000000;	// quarter note (0.25 seconds)
			12	:	durThresh = 6000000;  // quarter note (0.25 seconds)
			13	:	durThresh = 6000000;	// quarter note (0.25 seconds)
			14	:	durThresh = 6000000;	// quarter note (0.25 seconds)
			15 	: 	durThresh = 6000000;  // quarter note (0.25 seconds)
			default : durThresh = 6000000; // default: quarter note (0.25 seconds)
		endcase
	end			
endmodule
 
//////
//    module work with enables
// 	  start bit set high (allowing the doorbell sound to play) if chip enable just went low AND the doorbell isn't currently making mus
//	  This set of enables stops the doorbell from being reset with a new signal from the MCU
//////
module enables(input logic int_osc,
				input logic ce,
				input logic makingMusic,
				input logic [39:0] newFlattenedMCUout,
				output logic start,
				output logic [39:0] flattenedMCUout);
	// local signals
	logic twoAgoCE, lastCE;
	
	always_ff @(posedge int_osc) begin 
		twoAgoCE <= ce;
		lastCE <= twoAgoCE;
		// if CE was high two clock cycles ago and is now low, and the doorbell isn't currently making music
		if (lastCE == 1 && ce == 0 && makingMusic == 0) begin 
			flattenedMCUout <= newFlattenedMCUout;
			start <= 1;
		end
		else if (makingMusic == 1) start <= 0; // if the doorbell is already running, start gets 0
	end
	
endmodule


//////
//    takes in the unique signals from the unpacked spi data and creates a unique song based on them
//    uses an FSM to cycle through unique notes with unique durations
//////
module tune(input logic int_osc,
				input logic reset,
				input logic start,
				input logic[31:0] freqThreshold0,
				input logic[31:0] freqThreshold1,
				input logic[31:0] freqThreshold2,
				input logic[31:0] freqThreshold3,
				input logic[31:0] durThreshold0,
				input logic[31:0] durThreshold1,
				input logic[31:0] durThreshold2,
				input logic[31:0] durThreshold3,
				input logic[7:0] repThreshold,
				output logic makingMusic,
				output logic song);
		
	// local signals
	logic done, en, rep, stopCountFlag;
	logic[1:0] threshold;
	logic[1:0] counter = 0;
	logic[31:0] durThreshold;
	logic[31:0] freqThreshold;
	
	// assign repeat
	assign threshold = repThreshold[1:0]; 
	
	// if the counter has reached the threshold, then rep (the signal for the FMS to continue to note0 instead of completed) will go low
	assign rep = ~(counter == threshold); 
	
		
	// instantiate dur and freq modules
	duration howLong(int_osc, durThreshold, done);
	freqGenerator pitch(int_osc, makingMusic, freqThreshold, toneFreq);
	
	// state and next state definitions
	typedef enum logic[5:0] {idle, note0, note1, note2, note3, complete} statetype;
	statetype state, nextstate;
	
	// state register
	always_ff @(posedge int_osc) begin
		if (reset) state <= idle;
		else state <= nextstate;
	end
	
	// only play music when we aren't in the idle state
	// this is the enable for the frequency generator
	//always_ff @(posedge int_osc) begin
	//	if (state == idle) en <= 0;
	//	else en <= 1;
	// end
	
	// if completed doorbell chime, flag makingMusic goes low
	// also the enable for the frequency generator
	always_ff @(posedge int_osc) begin
		if (state == complete || state == idle) begin
			makingMusic <= 0;
			end
		else if (state == note0) begin
			makingMusic <= 1;
		end
	end
	
		
	// freq gets the frequency/duration of that note if its in that note's state
	always_ff @(posedge int_osc) begin
		if (state == note0) begin
			freqThreshold <= freqThreshold0;
			durThreshold <= durThreshold0;
		end
		else if (state == note1) begin
			freqThreshold <= freqThreshold1;
			durThreshold <= durThreshold1;
		end
		else if (state == note2) begin
			freqThreshold <= freqThreshold2;
			durThreshold <= durThreshold2;
		end
		else if (state == note3) begin
			freqThreshold <= freqThreshold3;
			durThreshold <= durThreshold3;
		end
	end
	
	// repition counter
	always_ff @(posedge int_osc) begin
		// if in the idle state, counter is 0
		if (state == idle) counter <= 0;
		// if in note0, the stop counting flag is 0
		else if (state == note0) stopCountFlag <= 0;
		
		// if in note3 and it hasn't increased the repitition counter
			// then counter is increased and it signals that it has counted already (stopCountFlag = 1)
		else if((state == note3) && !stopCountFlag) begin
			counter <= counter + 1;
			stopCountFlag <= 1;
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
				input logic[31:0] durThreshold,
				output logic done);
	
	// local signals
	logic[31:0] counter = 0;
	logic clkStrobe;
 	
	// strobe counter (modified from E155 L02 on 9/1/22)
	always_ff @(posedge int_osc) begin
		if(counter == durThreshold) begin
			 	counter <= 0;
				clkStrobe <= 1;
		end
		else  			begin
				clkStrobe <= 0;
				counter <= counter + 1;
		end
	end
	
	// assign output
	assign done = clkStrobe;
		
endmodule
				
//////
//    takes in a unique frequency threshold value corresponding to known frequencies, and creates a strobe clock at that frequency
/////
module freqGenerator(input logic int_osc,
					input logic on,
					input logic[31:0] freqThreshold,
					output logic pwm);
	
	// local signal
	logic[31:0] counter = 0;
	
	// strobe clock
	always_ff @(posedge int_osc) begin
		if (counter == freqThreshold || (!on)) counter <= 0;
		else counter <= counter + 1;
	end
	// if the strobe clock strobes, the signal toggles thus creating a square wave at the desired frequency
	always_ff @(posedge int_osc) begin
		if (counter == freqThreshold) pwm <= ~pwm;
	end

endmodule

/////////////////////////////////////////////
// SimTop
//   Top level module to allow for simulation without SPI 
// FOR SIMULATION ONLY
/////////////////////////////////////////////
module SimTop(input logic int_osc,  // for simulation purposes, delete and make an internal clock in the top module when done simulating
		   input  logic reset,
           input  logic [39:0] newFlattenedMCUout,
		   input  logic ce,
           output logic pwm,
		   output logic makingMusic);
                    
    logic [39:0] flattenedMCUout;//, newFlattenedMCUout;
	logic [3:0] tone0, tone1, tone2, tone3, durMCU0, durMCU1, durMCU2, durMCU3;
	logic [7:0] repThreshold;
	logic [31:0] freqThreshold0;
	logic [31:0] freqThreshold1;
	logic [31:0] freqThreshold2;
	logic [31:0] freqThreshold3;	
	logic [31:0] durThresh0, durThresh1, durThresh2, durThresh3;
	logic song;
	logic start;
	
	enables enabler(int_osc, ce, makingMusic, newFlattenedMCUout, start, flattenedMCUout);
	
	// decoder for the spi data to get the specific signals
	make_signals makingSignals(flattenedMCUout, tone0, tone1, tone2, tone3, durMCU0, durMCU1, durMCU2, durMCU3, repThreshold);
	
	//allTonesToFreq aT2F(tone0, tone1, tone2, tone3, freq0, freq1, freq2, freq3);
	allTonesToFreqThreshold aT2FT(tone0, tone1, tone2, tone3, freqThreshold0, freqThreshold1, freqThreshold2, freqThreshold3);
	
	//allDurMCU2Durs ad2ds(durMCU0, durMCU1, durMCU2, durMCU3, dur0, dur1, dur2, dur3);
	allDurMCU2DursThresh aD2DT(durMCU0, durMCU1, durMCU2, durMCU3, durThresh0, durThresh1, durThresh2, durThresh3);
	
	 tune tuner(int_osc, reset, start, freqThreshold0, freqThreshold1, freqThreshold2, freqThreshold3,  durThresh0, durThresh1, durThresh2, durThresh3, repThreshold, makingMusic, started, song);
	
	assign pwm = song;
endmodule



//////
//    Below are modules which have been depreciated but kept
// 	  These include decoders for frequnecy to an actual frequnecy in Hz and duration in ms
//////


// //////
// //    module to decode all tones into frequencies
// //////
// module allTonesToFreq(input logic[3:0] tone0,
// 					input logic[3:0] tone1,
// 					input logic[3:0] tone2,
// 					input logic[3:0] tone3,
// 					output logic[9:0] freq0,
// 					output logic[9:0] freq1,
// 					output logic[9:0] freq2,
// 					output logic[9:0] freq3);
					
// 	toneToFreq t2F0(tone0, freq0);
// 	toneToFreq t2F1(tone1, freq1);
// 	toneToFreq t2F2(tone2, freq2);
// 	toneToFreq t2F3(tone3, freq3);
	
// endmodule

// //////
// //    module to decode tone into frequency
// //////
// module toneToFreq(input logic[3:0] tone,
// 					output logic[9:0] freq);

// 	always_comb begin
// 		case(tone)
// 			0	:	freq = 220;	// A3
// 			1	:	freq = 247;	// B3
// 			2	:	freq = 262;	// C4
// 			3	: 	freq = 294;	// D4
// 			4	:	freq = 330;	// E4
// 			5	:	freq = 349;	// F4
// 			6 	:	freq = 392; // G4
// 			7	: 	freq = 440; // A4
// 			8	:	freq = 494;	// B4
// 			9	:	freq = 523;	// C5
// 			10	:	freq = 587;	// D5
// 			11	:	freq = 659;	// E5
// 			12	:	freq = 698; // F5
// 			13	:	freq = 784;	// G5
// 			14	:	freq = 880;	// A5
// 			15 	: 	freq = 262; // C4 (for the extra)
// 			default : freq = 262; // C4 (default)
// 		endcase
// 	end			
// endmodule


// //////
// //    module to decode all durMCUs into durations (ms)
// //////
// module allDurMCU2Durs(input logic[3:0] durMCU0,
// 					input logic[3:0] durMCU1,
// 					input logic[3:0] durMCU2,
// 					input logic[3:0] durMCU3,
// 					output logic[9:0] dur0,
// 					output logic[9:0] dur1,
// 					output logic[9:0] dur2,
// 					output logic[9:0] dur3);
					
// 	durMCUtoDuration d2d0(durMCU0, dur0);
// 	durMCUtoDuration d2d1(durMCU1, dur1);
// 	durMCUtoDuration d2d2(durMCU2, dur2);
// 	durMCUtoDuration d2d3(durMCU3, dur3);
	
// endmodule


// //////
// //    module to decode durD into duration in ms
// //////
// module durMCUtoDuration(input logic[3:0] durMCU,
// 					output logic[9:0] dur);

// 	always_comb begin
// 		case(durMCU)
// 			0	:	dur = 1000;	// whole note (1 second)
// 			1	:	dur = 1000;	// whole note (1 second)
// 			2	:	dur = 1000;	// whole note (1 second)
// 			3	: 	dur = 1000;	// whole note (1 second)
// 			4	:	dur = 1000;	// whole note (1 second)
// 			5	:	dur = 500;	// half note  (0.5 seconds)
// 			6 	:	dur = 500;  // half note  (0.5 seconds)
// 			7	: 	dur = 500;  // half note  (0.5 seconds)
// 			8	:	dur = 500;	// half note  (0.5 seconds)
// 			9	:	dur = 500;	// half note  (0.5 seconds)
// 			10	:	dur = 500;	// half note  (0.5 seconds)
// 			11	:	dur = 250;	// quarter note (0.25 seconds)
// 			12	:	dur = 250;  // quarter note (0.25 seconds)
// 			13	:	dur = 250;	// quarter note (0.25 seconds)
// 			14	:	dur = 250;	// quarter note (0.25 seconds)
// 			15 	: 	dur = 250;  // quarter note (0.25 seconds)
// 			default : dur = 250; // default: quarter note (0.25 seconds)
// 		endcase
// 	end			
// endmodule