// main.c
// Ava Fascetti and Joe Zales
// afascetti@hmc.edu || jzales@hmc.edu
// December 8, 2022 


#include <stdio.h>
#include <stdlib.h>
#include <stm32l432xx.h>
#include "STM32L432KC.h"
#include "PN532.h"

// Function prototypes
void mcu_to_fpga(char, char, char, char, char);
void process_and_send(char *rec);



/*********************************************************************
*
*       main()
*
*  I2C controller that communicates with PN532 peripheral:
*         turns on the PN532 RF field
*         collects ID data when a Mifare card is tapped to the PN532
*
*  Creates 5 unique bytes of signal data from 4 bytes of ID data:
*         4 of these bytes correspond directly to the 4 bytes of ID data
*         1 byte of signal data created from a combination of the 4 bytes of ID data
*
*  SPI controller that communicates with the UPduino FPGA peripheral:
*          sends the 5 bytes of signal data to the FPGA over SPI
*
*/
int main(void) {

  configureFlash();

  // enable GPIO clocks
  RCC->AHB2ENR |= (RCC_AHB2ENR_GPIOAEN | RCC_AHB2ENR_GPIOBEN | RCC_AHB2ENR_GPIOCEN);

  // the phase for the SPI clock is 0 and the polarity is 0
  initSPI(1, 0, 0);

  // initializes the I2C1
  initI2C();

  // initializes Timer 2
  RCC->APB1ENR1 |= RCC_APB1ENR1_TIM2EN;
  initTIM(TIM2);


  // All I2C Commands for the PN532 include:
  // preamble, startcode 1 & 2, packetlength, plchecksum, tfi, data, datachecksum, postamble
  // this simplifies to:
  //                    {front[0], front[1], front[2], pl, plchk, tfi, DATA, pdchk, postamble}

  char preamble = 0x00;
  char startcode1 = 0x00;
  char startcode2 = 0xFF;
  char postamble = 0x00;
  char front[3] = {preamble, startcode1, startcode2};
  char tfi = 0xD4; // D4 = host to PN532, D5 = PN543 to host


  char pli = 0x04; // packetlength of ilpt including tfi
  char plchki = 0xFC; // packetlength of ilpt checksum, pl + plchk = 0x...00
  char pdchki = 0xE1; // data checksum of ilpt, tfi + all data + pdchk = 0x...00
  
  // command for InListPassiveTarget (detect one card of 106 kbps Type A)
  char ilpt[11] = {front[0], front[1], front[2], pli, plchki, tfi, 0x4A, 0x01, 0x00, pdchki, postamble};
  char recL[24] = {0};


  char plr = 0x03; // packetlength of rfRegTest
  char plchkr = 0xFD; // packetlength checksum of rfRegTest
  char pdchkr = 0xD4; // data checksum of rfRegTest

  // command for RFRegulation Test (sending for 106 kbps and Mifare cards)
  char rfRegTest[10] = {front[0], front[1], front[2], plr, plchkr, tfi, 0x58, 0x00, pdchkr, postamble};
  char rRegTest[24] = {0};


  // loop: turn RF field on, listen for ID, process and send data to FPGA when ID tapped
  while(1){

    //// turning RF Field On
    sendI2C((0x48 >> 1), rfRegTest, 10); // send command
    while(digitalRead(I2C_IRQ)); // wait for IRQ line to drop
    int accepted = 0;
    accepted = read_ack((0x48 >> 1)); // read the ack back from the board
    
    // if the PN532 acknowledges that it should turn its RF Field on
    if(accepted) {

      // wait for RF Field to set up
      delay_millis(TIM2, 100); 

      // send InListPassiveTarget command
      sendI2C((0x48 >> 1), ilpt, 11);

      // wait for IRQ to drop (meaning the PN532 is about to ack)
      while(digitalRead(I2C_IRQ));

      // read the ack
      accepted = read_ack((0x48 >> 1));

      // if the PN532 acknowledges the command to listen for ID cards
      if(accepted) {

          // wait for IRQ to drop (meaning a card has been tapped)
          while(digitalRead(I2C_IRQ));

          // read output of InListPassiveTarget once an ID has been tapped
          readI2C((0x48 >> 1), 24, recL);

          // create signalData from ID data and send to FPGA
          process_and_send(recL);

          delay_millis(TIM2, 3000);
      }
    }
  }
  
}

// process_and_send:
//      takes a pointer to where the ID data is stored and 
//      creates signal data to send to the FPGA over SPI
void process_and_send(char *rec) {

    // initialize data to be sent to FPGA
    char signalData0 = 0b00000000; // n1n2
    char signalData1 = 0b00000000; // n3n4
    char signalData2 = 0b00000000; // d1d2
    char signalData3 = 0b00000000; // d3d4
    char signalData4 = 0b00000000; // times to repeat

    // bitswizzle bytes recieved from I2C
    // bytes 14, 15, 16, 17 correspond to the ID number
    signalData0 = rec[14];
    signalData1 = rec[15];
    signalData2 = rec[16];
    signalData3 = rec[17];

    // define the number of times to repeat to be combination of ID data mod 3
    signalData4 = (2*signalData0 + signalData1 + 2*signalData2 + signalData3) % 3;

    // send the signalData to the FPGA over SPI
    mcu_to_fpga(signalData0, signalData1, signalData2, signalData3, signalData4);

}

// mcu_to_fpga:
//      sends 5 bytes of data to the FPGA over SPI
void mcu_to_fpga(char signalData0, char signalData1, char signalData2, char signalData3, char signalData4) {

  // set chip enable high
  digitalWrite(SPI_CE, 1);

  // send each of the 5 signal data variables over SPI
  spiSendReceive(signalData0);
  spiSendReceive(signalData1);
  spiSendReceive(signalData2);    
  spiSendReceive(signalData3);
  spiSendReceive(signalData4);

  // set chip enable low
  digitalWrite(SPI_CE, 0);

}

/*************************** End of file ****************************/