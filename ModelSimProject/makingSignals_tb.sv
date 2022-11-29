
`timescale 10ns/1ns
/////////////////////////////////////////////
// spi_testing_tb
// Tests spi between MCU and FPGA for unique 6 signals
/////////////////////////////////////////////

module makingSignals_tb();

    logic [47:0] flattenedMCUout, flattenedMCUoutin;
	logic [7:0] sd0, sd1, sd2, sd3, sd4, sd5;
	logic [7:0] signalData0, signalData5, signalData1, signalData2, signalData3, signalData4;

    
    // device under test
    make_signals dut(flattenedMCUout, sd0, sd1, sd2, sd3, sd4, sd5);
    
    // test case
    initial begin   
        flattenedMCUoutin       <= 48'h5566778899AA;
  	signalData0 = 8'b01010101;  //55
	signalData1 = 8'b01100110;  //66
	signalData2 = 8'b01110111;  //77
	signalData3 = 8'b10001000;  //88
	signalData4 = 8'b10011001; //99
	signalData5 = 8'b10101010; //AA
    end


	initial begin
	#10;
	flattenedMCUout <= flattenedMCUoutin;

	#10;
	if(sd0 == signalData0)
		if(sd1 == signalData1)
			if(sd2 == signalData2)
				if(sd3 == signalData3)
					if(sd4 == signalData4)
						if(sd5 == signalData5)
							$display("Test passed!");
	else
		$display("Test failed!");
	end
    
endmodule