// PN532.c
// source for RFID breakout functions
// Authors: Ava Fascetti and Joe Zales
// Emails: afascetti@hmc.edu || jzales@hmc.edu
// Created: 11/6/22

#include "PN532.h"


#include "STM32L432KC.h"
#include "STM32L432KC_I2C.h"
#include "STM32L432KC_GPIO.h"
#include "STM32L432KC_RCC.h"



/* initializes the RFID breakout board as per PN532 data sheet
*   also initializes the I2C
*/
void initPN532() {
  
  // turns on GPIOB clock domains
  RCC->AHB2ENR |= (RCC_AHB2ENR_GPIOBEN);

  // setting the IRQ pin of the RFID chip to be an input on the MCU
  pinMode(RFID_IRQ, GPIO_INPUT);

  initI2C();

  // do the things here
  
  // send a custom address to I2CADR of PN532 (stars with address at 0x00)


}

/* reads the PN532 data memory location
*   returns the 4 byte identifier of the RFID card tapped
*/
uint32_t readPN532() {
  
  sendI2C(0x00, PN532_I2CDAT_reg, 1);


}