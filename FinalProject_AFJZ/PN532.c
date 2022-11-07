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
*
*/
void initPN532() {

  // do the things here
  
  // send a custom address to I2CADR of PN532 (stars with address at 0x00)


}