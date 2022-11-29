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
void mcu_to_fpga(char, char, char, char, char, char);



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

  char signalData0 = 219; //0b01010101;
  char signalData1 = 125; //0b01100110;
  char signalData2 = 219; //0b01110111;
  char signalData3 = 125; //0b10001000;
  char signalData4 = 0b10011001;
  char signalData5 = 0b10101010;

  //mcu_to_fpga(signalData0, signalData1, signalData2, signalData3, signalData4, signalData5);

  char toSend[1] = {0xDA};

  // send the signal data to the FPGA
  while(1){

    // testing I2C
    sendI2C(0x48, toSend, 1);
    delay_millis(TIM2, 5);

    //readI2C(0x00, 1);
    //delay_millis(TIM2, 5);

    //sendI2C(0xA0, 0xCC, 1);
    
    // wait while the IRQ bit remains high
    //while(digitalRead(RFID_IRQ));


    //mcu_to_fpga(signalData0, signalData1, signalData2, signalData3, signalData4, signalData5);
    //delay_millis(TIM2, 20);
  }
  


}

void mcu_to_fpga(char signalData0, char signalData1, char signalData2, char signalData3, char signalData4, char signalData5) {

  // set chip enable high
  digitalWrite(SPI_CE, 1);

  // send each of the 6 signal data variables over spi
  spiSendReceive(signalData0);
  spiSendReceive(signalData1);
  spiSendReceive(signalData2);    
  spiSendReceive(signalData3);
  spiSendReceive(signalData4);
  spiSendReceive(signalData5);

  // set chip enable low
  digitalWrite(SPI_CE, 0);

}

/*************************** End of file ****************************/