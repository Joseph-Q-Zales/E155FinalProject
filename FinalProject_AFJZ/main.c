///*********************************************************************
//*                    SEGGER Microcontroller GmbH                     *
//*                        The Embedded Experts                        *
//**********************************************************************

//-------------------------- END-OF-HEADER -----------------------------

//File    : main.c
//Purpose : Generic application start

//*/

//#include <stdio.h>
//#include <stdlib.h>
//#include <stm32l432xx.h>
//#include "STM32L432KC.h"
//#include "PN532.h"

//// Function prototypes
//void mcu_to_fpga(char, char, char, char, char, char);



///*********************************************************************
//*
//*       main()
//*
//*  Function description
//*   Application entry point.
//*/
//int main(void) {

//  configureFlash();
//  configureClock();
  
//  // enable GPIOA clock
//  RCC->AHB2ENR |= (RCC_AHB2ENR_GPIOAEN | RCC_AHB2ENR_GPIOBEN | RCC_AHB2ENR_GPIOCEN);

//  // "clock divide" = master clock frequency / desired baud rate
//  // the phase for the SPI clock is 0 and the polarity is 0
//  initSPI(1, 0, 0);

//  // initializes the PN532, also initializes the I2C1
//  initPN532();
  
//  RCC->APB1ENR1 |= RCC_APB1ENR1_TIM2EN;
//  initTIM(TIM2);


//  //////// do I2C


//  /////// calculate signal data -- ASSIGN THESE INTO THE VARIABLES BELOW

//  char signalData0 = 219;//0b01010101;
//  char signalData1 = 125;
//  char signalData2 = 100;
//  char signalData3 = 125;
//  char signalData4 = 0b10011001;
//  char signalData5 = 0b10101010;

//  char toSend[1] = {0xDA};

//  //mcu_to_fpga(signalData0, signalData1, signalData2, signalData3, signalData4, signalData5);

//  // send the signal data to the FPGA
//  while(1){
    
//    // testing I2C
//    //sendI2C(0x48, toSend, 1);
//    //delay_millis(TIM2, 5);

//    //readI2C(0x00, 1);
//    //for (int i = 0; i < 200; i++);

//    //sendI2C(0xA0, 0xCC, 1);
    
//    // wait while the IRQ bit remains high
//    //while(digitalRead(RFID_IRQ));

//    //readI2C(0x


    
//    mcu_to_fpga(signalData0, signalData1, signalData2, signalData3, signalData4, signalData5);
//    delay_millis(TIM2, 2000);
//  }
  



//}

//void mcu_to_fpga(char signalData0, char signalData1, char signalData2, char signalData3, char signalData4, char signalData5) {

//  // set chip enable high
//  digitalWrite(SPI_CE, 1);

//  // send each of the 6 signal data variables over spi
//  spiSendReceive(signalData0);
//  spiSendReceive(signalData1);
//  spiSendReceive(signalData2);    
//  spiSendReceive(signalData3);
//  spiSendReceive(signalData4);
//  spiSendReceive(signalData5);

//  // set chip enable low
//  digitalWrite(SPI_CE, 0);

//}

/*************************** End of file ****************************/



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



/*********************************************************************
*
*       main()
*
*  Function description
*   Application entry point.
*/
int main(void) {
  configureFlash();
  //configureClock();
  // enable GPIOA clock
  RCC->AHB2ENR |= (RCC_AHB2ENR_GPIOAEN | RCC_AHB2ENR_GPIOBEN | RCC_AHB2ENR_GPIOCEN);

  // "clock divide" = master clock frequency / desired baud rate
  // the phase for the SPI clock is 0 and the polarity is 0
  initSPI(1, 0, 0);


  // initializes the PN532, also initializes the I2C1
  initPN532();

  RCC->APB1ENR1 |= RCC_APB1ENR1_TIM2EN;
  initTIM(TIM2);

  /////// calculate signal data -- ASSIGN THESE INTO THE VARIABLES BELOW

  char signalData0 = 0b01101001; // n1n2
  char signalData1 = 0b10010001; // n3n4
  char signalData2 = 0b01011010; // d1d2
  char signalData3 = 0b01000111; // d3d4
  char signalData4 = 0b00000001; // times to repeat

  //mcu_to_fpga(signalData0, signalData1, signalData2, signalData3, signalData4, signalData5);


  ////// ALL TRANSACTIONS INCLUDE:
  //////  preamble, startcode 1 & 2, packetlength, plchecksum, tfi, data, datachecksum, postamble
  ////// this simplifies to:
  /////                    {front[0], front[1], front[2], pl, plchk, tfi, DATA, pdchk, postamble}

  char preamble = 0x00;
  char startcode1 = 0x00;
  char startcode2 = 0xFF;
  char postamble = 0x00;
  char front[3] = {preamble, startcode1, startcode2};

  char pl = 0x04; // packetlength including tfi
  char plchk = 0xFC; // packetlength checksum, pl + plchk = 0x...00
  char tfi = 0xD4; // D4 = host to PN532, D5 = PN543 to host
  char pdchk = 0xB5; // data checksum, tfi + all data + pdchk = 0x...00

  char diagnose[11] = {front[0], front[1], front[2], pl, plchk, tfi, 0x00, 0x00, 0x77, pdchk, postamble};
  
  char reciev[11] = {0};
  

  // send the signal data to the FPGA
  while(1){

    // testing I2C (PN532 address is 48, shifted by 1 for alingment
    //sendI2C((0x48 >> 1), toSend, 3);


    // testing diagnose command
    sendI2C((0x48 >> 1), diagnose, 11);
    delay_millis(TIM2, 5);

    // if communication line works, should recieve back: 
    // front, length (4), lchk, tfi (D5), data (01, 00, 78), pdchk, postamble
    // 00, 00, FF, 04, FC, D5, 01, 00, 78, B2, 00

    readI2C((0x48 >> 1), 11, reciev);
    delay_millis(TIM2, 5);



    
    // wait while the IRQ bit remains high
    //while(digitalRead(RFID_IRQ));


    //mcu_to_fpga(signalData0, signalData1, signalData2, signalData3, signalData4, signalData5);
    //delay_millis(TIM2, 20);
  }
  


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