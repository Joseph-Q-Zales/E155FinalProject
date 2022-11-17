/*********************************************************************
*                    SEGGER Microcontroller GmbH                     *
*                        The Embedded Experts                        *
**********************************************************************

-------------------------- END-OF-HEADER -----------------------------

File    : main.c
Purpose : Generic application start

*/

#include <stdio.h>
#include <stdlib.h>
#include <stm32l432xx.h>
#include "STM32L432KC.h"

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
  
  // enable GPIOA clock
  RCC->AHB2ENR |= (RCC_AHB2ENR_GPIOAEN | RCC_AHB2ENR_GPIOBEN | RCC_AHB2ENR_GPIOCEN);

  // "clock divide" = master clock frequency / desired baud rate
  // the phase for the SPI clock is 0 and the polarity is 0
  initSPI(1, 0, 0);
  initI2C();


  //////// do I2C


  /////// calculate signal data -- ASSIGN THESE INTO THE VARIABLES BELOW



  //char* signalData[6]; // fill this with our 6 bytes (wrong format rn)

  // EXAMPLE DATA FOR TESTING - FILL THESE WITH ACTUAL CALCULATIONS FROM THE I2C DATA
 // signalData[0] = 0b00000000;
 // signalData[1] = 0b11111111;
 // signalData[2] = 0b11110000;
 // signalData[3] = 0b00001111;
 // signalData[4] = 0b10101010;

 // signalData[5] = 0b11001100;

 //char* signalData = 0b000000001111111111110000000011111010101011001100;

  //char signalData = 0b01010101;
  char signalData0 = 0b01010101;
  char signalData1 = 0b01100110;
  char signalData2 = 0b01110111;
  char signalData3 = 0b10001000;
  char signalData4 = 0b10011001;
  char signalData5 = 0b10101010;

  //mcu_to_fpga(signalData0, signalData1, signalData2, signalData3, signalData4, signalData5);

  // send the signal data to the FPGA
  while(1){

    sendI2C(0xAB, 0xCC, 1);
    //delay_millis(TIM15, 50);
    //mcu_to_fpga(signalData0, signalData1, signalData2, signalData3, signalData4, signalData5);
  }
  
  // AA_55_0F_F0_AA_55_0F_F0
  //double signalData = 0b1010101001010101000011111111000010101010010101010000111111110000;




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
