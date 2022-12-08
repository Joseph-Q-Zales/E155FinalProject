// STM32L432KC_I2C.h
// Header for I2C functions
// Authors: Ava Fascetti and Joe Zales
// Emails: afascetti@hmc.edu || jzales@hmc.edu
// December 8, 2022 

#ifndef STM32L4_I2C_H
#define STM32L4_I2C_H

#include <stdint.h>
#include <stm32l432xx.h>

#define I2C_SCL PB6
#define I2C_SDA PB7
#define I2C_IRQ PB1

/* Enables the I2C peripheral and intializes its functions.
 * Refer to the datasheet for more low-level details. */ 
void initI2C();

/* initializes the controller communication on MCU
*     -- address: the address of the I2C peripheral
*     -- nbyts: number of bytes to send the peripheral
*     -- RdWr: set to 0 for writing, 1 for reading
 */
void comInitI2C(char address, char nbyts, uint16_t RdWr);

/* Transmits characters over I2C.
 *    -- address: the address of the I2C peripheral
 *    -- send: the characters to send over I2C 
 *    -- nbytes: the number of bytes being sent*/
void sendI2C(char address, char send[], char nbytes);

/* Reads characters over I2C.
 *    -- address: the address of the I2C peripheral
 *    -- nbytes: the amount of bytes to receive
 *    -- *reciev: pointer to the char array that the recieved data should fill into */
void readI2C(char address, char nbytes, char *reciev);

/* Reads ack over I2C.
 *    -- address: the address of the I2C peripheral
 *    returns: 1 if an ACK was read, 0 if no ACK was read */
int readack(char address);

#endif