/**
 * @file main.cpp
 * @brief Main test program for STM32F4xx and RF24
 * @dependencies std_periph_drivers
 * @used SPI2, GPIOE (Pins 2 & 3), USART1, printf (retargeted to USART1 @ref
 * retarget.cpp), TIM2 for simulation of __millis() function
 */
#include "stm32f4xx.h"
#include "RF24.h"
#include "compatibility.h"
#include "usart.h"
#include "gpio.h"
#include "retarget.h"

/** lwIP **/
#include "stm32f4x7_eth.h"
#include "netconf.h"
#include "main.h"
#include "lwip/tcp.h"


/** Host nRF24 address **/
static const uint64_t extAddress = 0xF0F0F0F0E2LL;

/** Test message **/
static char message[] = "<html>JUPI</html>!\n";

/**
 * Function setups RF24 radio. Additionally prints out registers.
 */
void setupRF(RF24 &radio) {
    radio.begin();
    radio.setChannel(0x4C);
    radio.setPayloadSize(32);
    radio.setPALevel(RF24_PA_LOW);
    radio.openWritingPipe(extAddress);
    radio.printDetails();
}

void LED_init() {
    RCC->AHB1ENR |= RCC_AHB1ENR_GPIODEN;
    __asm("dsb");
    GPIOD->MODER = (1 << 26);
}
/**
 * Main function.
 */
int main() {
    retarget_init();
    LED_init();
    RF24 rf24(7,8);
    setupRF(rf24);

    ETH_BSP_Config();
    LwIP_Init();

    printf("Setup complete!\r\n");

    while (1367) {
        //GPIOD->ODR ^= (1 << 13);
        rf24.write(message, sizeof(char) * strlen(message));
        /* check if any packet received */
        if (ETH_CheckFrameReceived()) {
            /* process received ethernet packet */
            LwIP_Pkt_Handle();
        }
        /* handle periodic timers for LwIP */
        LwIP_Periodic_Handle(__millis());
    }
}
