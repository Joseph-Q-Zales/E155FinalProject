/////////////////////////////////////////////
// enable_tb
// Tests the enable module
/////////////////////////////////////////////
module enable_tb();
    logic clk, ce, makingMusic, start;
    logic [39:0] flattenedMCUout, newFlattenedMCUout;

    enables dut(clk, ce, makingMusic, newFlattenedMCUout, start, flattenedMCUout);

    always begin
        clk = 1; #5; clk = 0; #5;
    end


    initial begin
        makingMusic = 0;	
	#11;
	ce = 1;
	#5
	newFlattenedMCUout = 3;
	#21;
	ce = 0;
        #10
	makingMusic = 1;
	//#20;
	//ce = 1;
	//#15;
	//newFlattenedMCUout = 12;
	//#5;
	//ce = 0;
	//#20;
	//makingMusic = 0;
	//#10;
        //ce = 1;
        //#15
	//newFlattenedMCUout = 15;
        //#5
        //ce = 0;
	//#1
	//makingMusic = 1;
	//#20;
	
    end

endmodule