
module tester(output logic oscil);
				
	HSOSC #(.CLKHF_DIV(2'b01))
		hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b0), .CLKHF(int_osc));
	
	logic[31:0] counter =0;
	

	always_ff @(posedge int_osc) begin
		if (counter == 27272) counter <= 0;
		else counter <= counter + 1;
	end
	always_ff @(posedge int_osc) begin
		if (counter == 27272) oscil <= ~oscil;
	end

		
endmodule