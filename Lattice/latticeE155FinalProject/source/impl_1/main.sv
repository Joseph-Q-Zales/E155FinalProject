/////////////////////////////////////////////
// top
//   Top level module with SPI interface and SPI core
/////////////////////////////////////////////

module top(input  logic clk,
           input  logic sck, 
           input  logic sdi,
           input  logic CE,
           output logic pwm);
                    
    logic [127:0] flattenedMCUout;
    MCU_spi spi(sck, sdi, flattenedMCUout);
	// AES_spi spi(sck, sdi, sdo, done, key, plaintext, cyphertext);   
    
endmodule

/////////////////////////////////////////////
// MCU_spi
//   SPI interface.  Shifts in the flattened MCU output
// 	 As only shifting in data, no need to wory about SDO
/////////////////////////////////////////////
// asking about how this works: get rid of cyphertext as sdi is a 1 bit signal that pushes cyphertext out slowly
module MCU_spi(input  logic sck, 
               input  logic sdi,
               output logic [127:0] flattenedMCUout);

    logic         sdodelayed, wasdone;
    logic [127:0] cyphertextcaptured;
               
    // assert load
    // apply 256 sclks to shift in key and plaintext, starting with plaintext[127]
    // then deassert load, wait until done
    // then apply 128 sclks to shift out cyphertext, starting with cyphertext[127]
    // SPI mode is equivalent to cpol = 0, cpha = 0 since data is sampled on first edge and the first
    // edge is a rising edge (clock going from low in the idle state to high).
	// TODO: ******DO WE NEED AN IF (CE) block
	always_ff @(posedge sck)
		flattenedMCUout = {flattenedMCUout, sdi};
    
endmodule

/////////////////////////////////////////////
// aes_spi
//   SPI interface.  Shifts in key and plaintext
//   Captures ciphertext when done, then shifts it out
//   Tricky cases to properly change sdo on negedge clk
/////////////////////////////////////////////


// asking about how this works: get rid of cyphertext as sdi is a 1 bit signal that pushes cyphertext out slowly
module AES_spi(input  logic sck, 
               input  logic sdi,
               output logic sdo,
               input  logic done,
               output logic [127:0] key, plaintext,
               input  logic [127:0] cyphertext);

    logic         sdodelayed, wasdone;
    logic [127:0] cyphertextcaptured;
               
    // assert load
    // apply 256 sclks to shift in key and plaintext, starting with plaintext[127]
    // then deassert load, wait until done
    // then apply 128 sclks to shift out cyphertext, starting with cyphertext[127]
    // SPI mode is equivalent to cpol = 0, cpha = 0 since data is sampled on first edge and the first
    // edge is a rising edge (clock going from low in the idle state to high).
    always_ff @(posedge sck)
        if (!wasdone)  {cyphertextcaptured, plaintext, key} = {cyphertext, plaintext[126:0], key, sdi};
        else           {cyphertextcaptured, plaintext, key} = {cyphertextcaptured[126:0], plaintext, key, sdi}; 
    
    // sdo should change on the negative edge of sck
    always_ff @(negedge sck) begin
        wasdone = done;
        sdodelayed = cyphertextcaptured[126];
    end
    
    // when done is first asserted, shift out msb before clock edge
    assign sdo = (done & !wasdone) ? cyphertext[127] : sdodelayed;
endmodule
