// STM32F401RE_I2C.h
// Header for SPI functions
// Authors: Ava Fascetti and Joe Zales
// Emails: afascetti@hmc.edu || jzales@hmc.edu
// Created: 11/6/22

#ifndef STM32L4_I2C_H
#define STM32L4_I2C_H

#include <stdint.h>
#include <stm32l432xx.h>

#define I2C_SCL PA9
#define I2C_SDA PA10

/* Enables the I2C peripheral and intializes its functions.
 * Refer to the datasheet for more low-level details. */ 
void initI2C();


/* Transmits a character (1 byte) over I2C.
 *    -- address: the address of the peripheral to send to over I2C
 *    -- w: the character received over I2C */
void sendI2C(char address, char w);


/* Reads a character (1 byte) over I2C.
 *    -- address: the address of the peripheral to send to over I2C
 *    -- w: the character received over I2C */
char readI2C(char address);

#endif