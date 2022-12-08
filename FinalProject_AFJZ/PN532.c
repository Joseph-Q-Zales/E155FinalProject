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



/* reads the PN532 data memory location
*   returns the 4 byte identifier of the RFID card tapped
*/
uint32_t readPN532() {
  
  sendI2C(0x00, PN532_I2CDAT_reg, 1);


}