// PN532.h
// Header for RFID breakout functions
// Authors: Ava Fascetti and Joe Zales
// Emails: afascetti@hmc.edu || jzales@hmc.edu
// Created: 11/6/22

#ifndef PN532_H
#define PN532_H

#include <stdint.h>
#include <stm32l432xx.h>
#include "STM32L432KC_I2C.h"

#define RFID_IRQ PB1

#define PN532_I2CDAT_reg 0xDA
/* initializes the RFID breakout board as per PN532 data sheet
*
*/
void initPN532();

#endif
