// STM32F401RE_I2C.c
// Source for SPI functions
// Authors: Ava Fascetti and Joe Zales
// Emails: afascetti@hmc.edu || jzales@hmc.edu
// Created: 11/6/22

#include "STM32L432KC.h"
#include "STM32L432KC_I2C.h"
#include "STM32L432KC_GPIO.h"
#include "STM32L432KC_RCC.h"

/* Enables the I2C peripheral and intializes its functions.
 * Refer to the datasheet for more low-level details. */ 
void initI2C() {

  // turns on GPIOA clock domains
  RCC->AHB2ENR |= (RCC_AHB2ENR_GPIOAEN);
  
  // Turn on HSI 16 MHz clock
  RCC->CR |= (RCC_CR_HSION);  
  // sets HSI16 as the clock for I2C
  RCC->CCIPR |= (0b10 << RCC_CCIPR_I2C1SEL_Pos);

  // turns on the I2C 1 for the clock domain
  RCC->APB1ENR1 |= (RCC_APB1ENR1_I2C1EN);

  // initially assinging I2C pins
  pinMode(I2C_SCL, GPIO_ALT); // I2C1_SCL
  pinMode(I2C_SDA, GPIO_ALT); // I2C1_SDA

  // set to AF04 for I2C alternate functions
  GPIOA->AFR[1] |= (0b0100 << GPIO_AFRH_AFSEL9_Pos);  // SCL to af4
  GPIOA->AFR[1] |= (0b0100 << GPIO_AFRH_AFSEL10_Pos); // SDA to af4

  // OSPEEDR?

  // turning off clock stretching as not supported by RFID peripheral
  I2C1->CR1 |= (I2C_CR1_NOSTRETCH_Msk);

  // turning analog noise filter on
  I2C1->CR1 &= ~(I2C_CR1_ANFOFF_Msk);
  

  // cleraning TIMINGR section
  I2C1->TIMINGR &= ~(I2C_TIMINGR_PRESC_Msk); 
  I2C1->TIMINGR &= ~(I2C_TIMINGR_SCLDEL_Msk); 
  I2C1->TIMINGR &= ~(I2C_TIMINGR_SDADEL_Msk);
  I2C1->TIMINGR &= ~(I2C_TIMINGR_SCLH_Msk);
  I2C1->TIMINGR &= ~(I2C_TIMINGR_SCLL_Msk);

  // from table 182 for a I2C clock of 16MHz, and I2C running at 100 kHz
  // PRESC = 3
  // SCLL = 0x13
  // ____________
  // t_SCLL = 20 x 250 ns = 5.0 us
  // SCLH = 0xF
  // ____________
  // t_SCHLH = 16 x250 ns = 4 us
  // t_SCL = ~10 us
  // SDADEL = 0x2
  // ____________
  // t_SDADEL = 2 x 250 ns = 500 ns
  // SCLDEL = 0x4
  // ____________
  // t_SCLDEL = 5 x 250 ns = 1250 ns
  I2C1->TIMINGR |= (3 << I2C_TIMINGR_PRESC_Pos); 
  I2C1->TIMINGR |= (0x4 << I2C_TIMINGR_SCLDEL_Pos);
  I2C1->TIMINGR |= (0x2 << I2C_TIMINGR_SDADEL_Pos);
  I2C1->TIMINGR |= (0xF << I2C_TIMINGR_SCLH_Pos);
  I2C1->TIMINGR |= (0x13 << I2C_TIMINGR_SCLL_Pos);
  
  // turning on the peripheral
  I2C1->CR1 |= I2C_CR1_PE;
}


/* Transmits a character (1 byte) over I2C.
 *    -- address: the address of the peripheral to send to over I2C
 *    -- w: the character received over I2C */
void sendI2C(char address, char w) {

}

/* Reads a character (1 byte) over I2C.
 *    -- address: the address of the peripheral to send to over I2C
 *    -- w: the character received over I2C */
char readI2C(char address) {

return (char) 0;

}
