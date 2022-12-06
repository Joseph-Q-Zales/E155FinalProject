// STM32L432KC_I2C.h
// Header for I2C functions
// Authors: Ava Fascetti and Joe Zales
// Emails: afascetti@hmc.edu || jzales@hmc.edu
// Created: 11/6/22

#ifndef STM32L4_I2C_H
#define STM32L4_I2C_H

#include <stdint.h>
#include <stm32l432xx.h>

#define I2C_SCL PB6
#define I2C_SDA PB7
#define I2C_IRQ PB1
#define I2C_reset PB0

/* Enables the I2C peripheral and intializes its functions.
 * Refer to the datasheet for more low-level details. */ 
void initI2C();


/* initializes the controller communication on MCU
*     -- address: the address of the peripheral to send to
*     -- nbyts: number of byts to send the peripheral
*     -- RdWr: set to 0 for writing, 1 for reading
 */
void comInitI2C(char address, char nbyts, uint16_t RdWr);

/* Transmits a character (1 byte) over I2C.
 *    -- address: the address of the peripheral to send to over I2C
 *    -- send: the character received over I2C 
 *    -- nbytes: the number of bytes being sent*/
void sendI2C(char address, char send[], char nbytes);


/* Reads a character (1 byte) over I2C.
 *    -- address: the address of the peripheral to send to over I2C
 *    -- nbytes: the amount of bytes to receive */
void readI2C(char address, char nbytes, char *reciev);

#endif