

`timescale 10ns/1ns
/////////////////////////////////////////////
// spi_testing_tb
// Tests spi between MCU and FPGA for unique 6 signals
/////////////////////////////////////////////

module makingSignals_tb();

    logic [47:0] flattenedMCUout, flattenedMCUoutin;
	logic [7:0] sd0, sd1, sd2, sd3, sd4, sd5;

    
    // device under test
    make_signals dut(flattenedMCUout, sd0, sd1, sd2, sd3, sd4, sd5);
    
    // test case
    initial begin   
        flattenedMCUoutin       <= 48'h5566778899AA;
    end


  //char signalData0 = 0b01010101;  55
 // char signalData1 = 0b01100110;  66
  //char signalData2 = 0b01110111;  77
  //char signalData3 = 0b10001000;  88
  //char signalData4 = 0b10011001; 99
  //char signalData5 = 0b10101010; AA


	initial begin
	#10;
	flattenedMCUout <= flattenedMCUoutin;

	#10;
	end
    
endmodule