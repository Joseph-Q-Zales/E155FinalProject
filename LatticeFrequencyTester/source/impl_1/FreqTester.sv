
module tester(output logic oscil);
	// 24MHz		
		// Internal high-speed oscillator (instantiates the 48 MHz clock)
	HSOSC #(.CLKHF_DIV(2'b01))
		hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));
	
	logic[31:0] counter = 0;
	logic[31:0] THRESHOLD = 15305;
	

	always_ff @(posedge int_osc) begin
		if (counter == THRESHOLD) counter <= 0;
		else counter <= counter + 1;
	end
	always_ff @(posedge int_osc) begin
		if (counter == THRESHOLD) oscil <= ~oscil;
	end

		
endmodule