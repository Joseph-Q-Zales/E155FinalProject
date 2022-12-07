
/*********************************************************************
*                    SEGGER Microcontroller GmbH                     *
*                        The Embedded Experts                        *
**********************************************************************
-------------------------- END-OF-HEADER -----------------------------
File    : main.c
Purpose : Generic application start
*/

//#include <stdio.h>
//#include <stdlib.h>
//#include <stm32l432xx.h>
//#include "STM32L432KC.h"

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
*  Function description
*   Application entry point.
*/
int main(void) {

  configureFlash();

  // enable GPIOA clock
  RCC->AHB2ENR |= (RCC_AHB2ENR_GPIOAEN | RCC_AHB2ENR_GPIOBEN | RCC_AHB2ENR_GPIOCEN);

  // the phase for the SPI clock is 0 and the polarity is 0
  initSPI(1, 0, 0);

  // initializes the PN532, also initializes the I2C1
  initPN532();

  // initializes Timer 2
  RCC->APB1ENR1 |= RCC_APB1ENR1_TIM2EN;
  initTIM(TIM2);

  //char signalData0 = 0b01101001; // n1n2
  //char signalData1 = 0b10010001; // n3n4
  //char signalData2 = 0b01011010; // d1d2
  //char signalData3 = 0b01000111; // d3d4
  //char signalData4 = 0b00000001; // times to repeat


  ////// ALL TRANSACTIONS INCLUDE:
  //////  preamble, startcode 1 & 2, packetlength, plchecksum, tfi, data, datachecksum, postamble
  ////// this simplifies to:
  /////                    {front[0], front[1], front[2], pl, plchk, tfi, DATA, pdchk, postamble}

  char preamble = 0x00;
  char startcode1 = 0x00;
  char startcode2 = 0xFF;
  char postamble = 0x00;
  char front[3] = {preamble, startcode1, startcode2};
  char tfi = 0xD4; // D4 = host to PN532, D5 = PN543 to host


  char pli = 0x04; // packetlength of ilpt including tfi
  char plchki = 0xFC; // packetlength of ilpt checksum, pl + plchk = 0x...00
  char pdchki = 0xE1; // data checksum of ilpt, tfi + all data + pdchk = 0x...00
  
  // command for InListPassiveTarget
  char ilpt[11] = {front[0], front[1], front[2], pli, plchki, tfi, 0x4A, 0x01, 0x00, pdchki, postamble};
  char recL[24] = {0};


  char plr = 0x03; // packetlength of rfRegTest
  char plchkr = 0xFD; // packetlength checksum of rfRegTest
  char pdchkr = 0xD4; // data checksum of rfRegTest

  // command for RFRegulation Test (sending for 106 kbps and Mifare cards)
  char rfRegTest[10] = {front[0], front[1], front[2], plr, plchkr, tfi, 0x58, 0x00, pdchkr, postamble};
  char rRegTest[24] = {0};


  // send the signal data to the FPGA
  while(1){

    // turning RF Field On
    sendI2C((0x48 >> 1), rfRegTest, 10); // send command
    while(digitalRead(I2C_IRQ)); // wait for IRQ line to drop
    int accepted = 0;
    accepted = read_ack((0x48 >> 1)); // read the ack back from the board
    // TODO add in conditional only if accepted ?? otherwise if it fails it doesn't matter
    delay_millis(TIM2, 100); // wait for RF Field to set up

    // send InListPassiveTarget command
    sendI2C((0x48 >> 1), ilpt, 11);

    // wait for IRQ to drop (meaning the PN532 is about to ack)
    while(digitalRead(I2C_IRQ));

    // read the ack
    accepted = read_ack((0x48 >> 1));

    // wait for IRQ to drop (meaning a card has been tapped)
    while(digitalRead(I2C_IRQ));

    // read output of InListPassiveTarget once an ID has been tapped
    readI2C((0x48 >> 1), 24, recL);

    // create signalData from ID info and send to FPGA
    process_and_send(recL);

    delay_millis(TIM2, 20);

  }
  

}

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

    signalData4 = (signalData0 + signalData1 + signalData2 + signalData3) % 3;

    mcu_to_fpga(signalData0, signalData1, signalData2, signalData3, signalData4);

}

void mcu_to_fpga(char signalData0, char signalData1, char signalData2, char signalData3, char signalData4) {

  // set chip enable high
  digitalWrite(SPI_CE, 1);

  // send each of the 6 signal data variables over spi
  spiSendReceive(signalData0);
  spiSendReceive(signalData1);
  spiSendReceive(signalData2);    
  spiSendReceive(signalData3);
  spiSendReceive(signalData4);

  // set chip enable low
  digitalWrite(SPI_CE, 0);

}

/*************************** End of file ****************************/