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

  // turns on GPIOB clock domains
  RCC->AHB2ENR |= (RCC_AHB2ENR_GPIOBEN);
  
  // Turn on HSI 16 MHz clock
  RCC->CR |= (RCC_CR_HSION);  
  // sets HSI16 as the clock for I2C
  RCC->CCIPR |= (0b10 << RCC_CCIPR_I2C1SEL_Pos);

  // turns on the I2C 1 for the clock domain
  RCC->APB1ENR1 |= (RCC_APB1ENR1_I2C1EN);

  // initially assigning I2C pins
  pinMode(I2C_SCL, GPIO_ALT); // I2C1_SCL
  pinMode(I2C_SDA, GPIO_ALT); // I2C1_SDA

  // set to AF04 for I2C alternate functions
  GPIOB->AFR[0] |= (0b0100 << GPIO_AFRL_AFSEL6_Pos);  // SCL to af4 (PB6)
  GPIOB->AFR[0] |= (0b0100 << GPIO_AFRL_AFSEL7_Pos); // SDA to af4  (PB7)
  //GPIOA->AFR[1] |= (0b0100 << GPIO_AFRH_AFSEL9_Pos);  // SCL to af4
  //GPIOA->AFR[1] |= (0b0100 << GPIO_AFRH_AFSEL10_Pos); // SDA to af4

  // set output speed type to high for I2C
  GPIOB->OSPEEDR |= (GPIO_OSPEEDR_OSPEED3);

  // turning on pull up resistors
  //GPIOB->PUPDR |= (_VAL2FLD(GPIO_PUPDR_PUPD6, 0b01));
  //GPIOB->PUPDR |= (_VAL2FLD(GPIO_PUPDR_PUPD7, 0b01));

  // turning on open drain
  GPIOB->OTYPER |= (GPIO_OTYPER_OT6);
  GPIOB->OTYPER |= (GPIO_OTYPER_OT7);
  


  //TODO determine if we actually need stretch
  //// turning off clock stretching as not supported by RFID peripheral
  //I2C1->CR1 |= (I2C_CR1_NOSTRETCH);

  // turning analog noise filter on
  I2C1->CR1 &= ~(I2C_CR1_ANFOFF);
  
   // turns on the RX interupt enable
  I2C1->CR1 |= (I2C_CR1_RXIE);
  // turns on the TX interupt enable
  I2C1->CR1 |= (I2C_CR1_TXIE);
  // turns on the TC interupt enable
  I2C1->CR1 |= (I2C_CR1_TCIE);

  // clearing TIMINGR section
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

  // turn on autoend
  I2C1 -> CR2 |= I2C_CR2_AUTOEND;


  // turning on the peripheral
  I2C1->CR1 |= I2C_CR1_PE;
}

/* initializes the controller communication on MCU
*     -- address: the address of the peripheral to send to
*     -- nbyts: number of byts to send the peripheral
*     -- RdWr: set to 0 for writing, 1 for reading
*/
void comInitI2C(char address, char nbyts, uint16_t RdWr) {

  // 7 bit addressing mode
  I2C1->CR2 &= ~(I2C_CR2_ADD10);

  // master only sends 7 bits followed by r/w
  I2C1->CR2 |= (I2C_CR2_HEAD10R);
  
  // set slave address to send to 0x00 (the general call address for the PN532)
  I2C1->CR2 &= ~(I2C_CR2_SADD_Msk);

  I2C1->CR2 |= (address << 1);

  // set transfer direction (RD_WRN)
  if(RdWr) { // if RdWr is a 1, we are reading
    I2C1->CR2 |= (I2C_CR2_RD_WRN);
  }
  else { // sets to 0 if a write transfer
    I2C1->CR2 &= ~(I2C_CR2_RD_WRN);
  }


  I2C1->CR2 &= ~(I2C_CR2_NBYTES_Msk);

  // set NBYTES (numb bytes to send)
  I2C1->CR2 |= _VAL2FLD(I2C_CR2_NBYTES, nbyts);

    // enables the start bit
  //I2C1->CR2 |= (I2C_CR2_START);
  I2C1 -> CR2 |= (1 << 13);

}

/* Transmits characters over I2C.
 *    -- address: the address of the peripheral to send to over I2C
 *    -- send: the character received over I2C 
 *    -- nbytes: the number of bytes being sent*/
void sendI2C(char address, char send[], char nbytes) {
  
  comInitI2C(address, nbytes, 0);

  I2C1->ISR |= (I2C_ISR_TXIS_Msk);

  // for loop going through entire send array
  for(int i = 0; i < nbytes; i++) {
    
    if (i != 0) {
      // while TXIS not equal to 1, wait
      //while (!(I2C1->ISR & I2C_ISR_TXE));
      while (!(I2C1->ISR & I2C_ISR_TXIS));
    }

    // once it goes high, set the transfer register (TXDR) to be w
    *((volatile char *) (&I2C1->TXDR)) = send[i]; // writing the sending character to DR

   }

}

/* Reads characters over I2C.
 *    -- address: the address of the peripheral to send to over I2C
 *    -- nbytes: the amount of bytes to receive */
readI2C(char address, char nbytes, char *reciev) {
  
  comInitI2C(address, nbytes, 1);

  //while (!(I2C1->ISR & I2C_ISR_RXNE));

  // for loop going through entire send array
  for(int i = 0; i < nbytes; i++) {
    
    if (i != 0) {
      // while RXNE not equal to 1, wait
      while (!(I2C1->ISR & I2C_ISR_RXNE));
    }

    // once it goes high, read RXDR and store in array
    reciev[i] = (volatile char) I2C1->RXDR;

   }

///* initializes the controller communication on MCU
//*     -- address: the address of the peripheral to send to
//*     -- nbyts: number of byts to send the peripheral
//*     -- RdWr: set to 0 for writing, 1 for reading
//*/
//void comInitI2Cr(char address, char nbyts, uint16_t RdWr) {

//  // 7 bit addressing mode
//  I2C1->CR2 &= ~(I2C_CR2_ADD10);

//  // master only sends 7 bits followed by r/w
//  I2C1->CR2 |= (I2C_CR2_HEAD10R);
  
//  // set slave address to send to 0x00 (the general call address for the PN532)
//  I2C1->CR2 &= ~(I2C_CR2_SADD_Msk);

//  I2C1->CR2 |= (address << 1);

//  // set transfer direction (RD_WRN)
//  if(RdWr) { // if RdWr is a 1, we are reading
//    I2C1->CR2 |= (I2C_CR2_RD_WRN);
//  }
//  else { // sets to 0 if a write transfer
//    I2C1->CR2 &= ~(I2C_CR2_RD_WRN);
//  }

//  // set NBYTES (numb bytes to send)
//  I2C1->CR2 |= _VAL2FLD(I2C_CR2_NBYTES, nbyts);

//    // enables the start bit
//  //I2C1->CR2 |= (I2C_CR2_START);
//  I2C1 -> CR2 |= (1 << 13);

//}

}
