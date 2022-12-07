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

  //char diagnose[11] = {front[0], front[1], front[2], pl, plchk, tfi, 0x00, 0x00, 0x77, pdchk, postamble};
  //char reciev[16] = {0};

  //pl = 0x02;
  //plchk = 0xFE;
  //pdchk = 0x2A;
  
  //char getfv[9] = {front[0], front[1], front[2], pl, plchk, tfi, 0x02, pdchk, postamble};
  //char reci[24] = {0};



  //pl = 0x04;
  //plchk = 0xFC;
  //pdchk = 0x7F;

  //char resetP35[11] = {front[0], front[1], front[2], pl, plchk, tfi, 0x0E, 0x9F, 0x00, pdchk, postamble};
  //char recievT[16] = {0};


  pl = 0x04;
  plchk = 0xFC;
  pdchk = 0xE1;
  
  char ilpt[11] = {front[0], front[1], front[2], pl, plchk, tfi, 0x4A, 0x01, 0x00, pdchk, postamble};
  char recL[24] = {0};


  //pl = 0x02;
  //plchk = 0xFE;
  //pdchk = 0x28;
  
  //char getGS[9] = {front[0], front[1], front[2], pl, plchk, tfi, 0x04, pdchk, postamble};
  //char recTes[24] = {0};


  //pl = 0x02;
  //plchk = 0xFE;
  //pdchk = 0xA6;
  
  //char tgget[9] = {front[0], front[1], front[2], pl, plchk, tfi, 0x86, pdchk, postamble};
  //char rec[12] = {0};


 // for(int i=0; i<3; i++) {
    
    // testing resetP53 command
 //   sendI2C((0x48 >> 1), resetP35, 11);
//    delay_millis(TIM2, 5);

 //   readI2C((0x48 >> 1), 16, recievT);  // EXPECT BACK 12 bytes
 //   delay_millis(TIM2, 5);


 // }

  // set IRQ pin as an output and drive it to be 0
  //pinMode(I2C_IRQ, GPIO_OUTPUT);
  //pinMode(I2C_reset, GPIO_OUTPUT);

  //digitalWrite(I2C_IRQ, PIO_HIGH);
  //digitalWrite(I2C_IRQ, PIO_LOW);
  //delay_millis(TIM2, 1);
  //digitalWrite(I2C_IRQ, PIO_HIGH);
  //delay_millis(TIM2, 5);

  //digitalWrite(I2C_IRQ, PIO_LOW);




  // send the signal data to the FPGA
  while(1){

    // testing I2C (PN532 address is 48, shifted by 1 for alingment
    //sendI2C((0x48 >> 1), toSend, 3);


    // testing diagnose command
    //sendI2C((0x48 >> 1), diagnose, 11);
    //delay_millis(TIM2, 5);

    // if communication line works, should recieve back: 
    // 01, front, length (4), lchk, tfi (D5), data (01, 00, 78), pdchk, postamble
    // 01, 00, 00, FF, 04, FC, D5, 01, 00, 78, B2, 00
    // BUT INSTEAD GETTING
    // 01, 00, 00, FF, 00, FF, 00, 00, 00, 77, B5, 00

    //readI2C((0x48 >> 1), 16, reciev);  // EXPECT BACK 12 bytes
    //delay_millis(TIM2, 5);





    // testing resetP53 command
    //sendI2C((0x48 >> 1), resetP35, 11);
    //delay_millis(TIM2, 5);

    //readI2C((0x48 >> 1), 16, recievT);  // EXPECT BACK 12 bytes
    //delay_millis(TIM2, 5);


    // testing getFirmwareVersion command
    //sendI2C((0x48 >> 1), getfv, 9);
    //delay_millis(TIM2, 5);

    // if getFirmwareVersion works, should recieve back: 
    // 01, front, length (4), lchk, tfi (D5), data (01, 00, 78), pdchk, postamble
    // 01, 00, 00, FF, 06, FA, D5, 01, 32, 01, 06, 07, EA, 00
    
    //readI2C((0x48 >> 1), 24, reci); // EXPECT BACK 14 bytes
    //delay_millis(TIM2, 5);




    sendI2C((0x48 >> 1), ilpt, 11);
    while(digitalRead(I2C_IRQ));

    int accepted = 0;
    
    accepted = read_ack((0x48 >> 1));
    //delay_millis(TIM2, 5);

    // wait for it to drop
    while(digitalRead(I2C_IRQ));

    // wait for it to go high again
    readI2C((0x48 >> 1), 24, recL);



    



    // testing TgGetData
    //sendI2C((0x48 >> 1), tgget, 9);
    //delay_millis(TIM2, 5);

    // if TgGetData works, should recieve back: 
    // 01, front, length (4), lchk, tfi (D5), data (87, 00 or 01, 4 bytes), pdchk, postamble
    // 01, 00, 00, FF, 07, F9, D5, 87, 00/01, xx, xx, xx, xx, CHECKSUM, 00

    //readI2C((0x48 >> 1), 12, rec);   // EXPECT BACK 15 bytes
    //delay_millis(TIM2, 5);


    // testing InListPassiveTarget
    //sendI2C((0x48 >> 1), ilpt, 11);
    //delay_millis(TIM2, 5);

    // if InListPassiveTarget works, should recieve back: 
    // 01, front, length (4 or 12), lchk, tfi (D5), data (4B, 01, 00 or 01, ), pdchk, postamble
    // 

    //readI2C((0x48 >> 1), 24, recL);   // EXPECT BACK 12 bytes or 24
    //delay_millis(TIM2, 5);


    // testing getGeneralStatus
    //sendI2C((0x48 >> 1), getGS, 9);
    //delay_millis(TIM2, 5);

    // if InListPassiveTarget works, should recieve back: 
    // 01, front, length (4 or 12), lchk, tfi (D5), data (4B, 01, 00 or 01, ), pdchk, postamble
    // 

    //readI2C((0x48 >> 1), 24, recTes);   // EXPECT BACK 12 bytes or 24
    //delay_millis(TIM2, 5);

    
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