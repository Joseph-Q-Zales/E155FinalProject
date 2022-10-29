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
void mcu_to_fpga(char*);



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


  //////// do I2C


  /////// calculate signal data
  char* signalData[6]; // fill this with our 6 bytes (wrong format rn)


  // send the signal data to the FPGA
  mcu_to_fpga(signalData);


}

void mcu_to_fpga(char * signalData) {

  int i;
  
  // write CE high
  digitalWrite(SPI_CE, 1);

  // send signal data
  for(i = 0; i < 6; i++) {
    spiSendReceive(signalData[i]);
  }

  // write CE low
  digitalWrite(SPI_CE, 0);

}

/*************************** End of file ****************************/
