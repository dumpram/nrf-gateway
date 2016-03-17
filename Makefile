# Put your stlink folder here so make burn will work.
STLINK=~/arm-workspace/stlink

# Put your source files here (or *.c, etc)
SRCS = src/*.cpp
SRCS += src/*.c

# Put your inc files here (or *.h, etc)
INCS=inc/

# Binaries will be generated with this name (.elf, .bin, .hex, etc)
PROJ_NAME = nrf-gateway

# Put your STM32F4 library code directory here
STM_COMMON = lib/stm32

# Standard peripheral library
STD_PERIPH_LIB=$(STM_COMMON)/STM32F4xx_StdPeriph_Driver

# FreeRTOS lib
FREE_RTOS_LIB = lib/FreeRTOS_v6.1.0

# Standard peripheral sources
STD_PERIPH_SRC = $(STD_PERIPH_LIB)/src/stm32f4xx_spi.c
STD_PERIPH_SRC += $(STD_PERIPH_LIB)/src/stm32f4xx_tim.c
STD_PERIPH_SRC += $(STD_PERIPH_LIB)/src/stm32f4xx_gpio.c
STD_PERIPH_SRC += $(STD_PERIPH_LIB)/src/stm32f4xx_rcc.c
STD_PERIPH_SRC += $(STD_PERIPH_LIB)/src/stm32f4xx_usart.c
STD_PERIPH_SRC += $(STD_PERIPH_LIB)/src/misc.c
STD_PERIPH_SRC += $(STD_PERIPH_LIB)/src/stm32f4xx_syscfg.c

# FreeRTOS sources
FREE_RTOS_SRC = $(FREE_RTOS_LIB)/*.c

# FreeRTOS include
FREE_RTOS_INC = -I$(FREE_RTOS_LIB)/include
FREE_RTOS_INC += -I$(FREE_RTOS_LIB)/portable/GCC/ARM_CM3

# FreeRTOS portable source
FREE_RTOS_SRC += $(FREE_RTOS_LIB)/portable/GCC/ARM_CM3/*.c
FREE_RTOS_SRC += $(FREE_RTOS_LIB)/portable/MemMang/heap_2.c

# lwIP stack source files
LWIP_SRC = lib/lwip_v1.3.2/src/api/*.c
LWIP_SRC += lib/lwip_v1.3.2/src/core/*.c
LWIP_SRC += lib/lwip_v1.3.2/src/netif/*.c
LWIP_SRC += lib/lwip_v1.3.2/src/netif/ppp/*.c
LWIP_SRC += lib/lwip_v1.3.2/src/core/*.c
LWIP_SRC += lib/lwip_v1.3.2/src/core/ipv4/*.c
LWIP_SRC += lib/lwip_v1.3.2/src/core/snmp/*.c

# lwIP STM32F4x7 port files
LWIP_SRC += lib/lwip_v1.3.2/port/STM32F4x7/Standalone/*.c

# lwIP stack include files
LWIP_INC = -Ilib/lwip_v1.3.2/port/STM32F4x7/
LWIP_INC += -Ilib/lwip_v1.3.2/port/STM32F4x7/Standalone/
LWIP_INC += -Ilib/lwip_v1.3.2/src/netif/ppp/
LWIP_INC += -Ilib/lwip_v1.3.2/src/include/ipv4/
LWIP_INC += -Ilib/lwip_v1.3.2/src/include/ipv6/lwip/
LWIP_INC += -Ilib/lwip_v1.3.2/src/include/lwip/
LWIP_INC += -Ilib/lwip_v1.3.2/src/include/

# stm32f4 ethernet driver
STD_ETH_SRC = lib/stm32/STM32F4x7_ETH_Driver/src/*.c
STD_ETH_INC = lib/stm32/STM32F4x7_ETH_Driver/inc/

# Linker script
STM_LD = stm32f4xx_flash.ld

# Normally you shouldn't need to change anything below this line!
################################################################################

CC=arm-none-eabi-g++
OBJCOPY=arm-none-eabi-objcopy

# Compiler flags
CFLAGS  = -g -O2 -w -T$(STM_LD) -std=c++11 --specs=nosys.specs -fpermissive
CFLAGS += -D USE_STDPERIPH_DRIVER -D SERIAL_DEBUG
CFLAGS += -mlittle-endian -mthumb -mcpu=cortex-m4 -mthumb-interwork
CFLAGS += -mfloat-abi=hard -mfpu=fpv4-sp-d16

# User includes
CFLAGS += -I$(INCS)
CFLAGS += $(LWIP_INC)
CFLAGS += -I$(STD_ETH_INC)

# Include files from STM libraries
CFLAGS += -I$(STM_COMMON)/CMSIS/Include
CFLAGS += -I$(STM_COMMON)/CMSIS/ST/STM32F4xx/Include

# Include from standard peripheral library
CFLAGS += -I$(STD_PERIPH_LIB)/inc

# Include FreeRTOS
CFLAGS += $(FREE_RTOS_INC)

# Size optimization
CFLAGS+=-fno-exceptions
CFLAGS+=-fno-builtin
CFLAGS+=-flto
CFLAGS+=-fno-rtti
CFLAGS+=--specs=nano.specs

# add startup file to build
SRCS += startup_stm32f4xx.s

# Standard peripheral library src
SRCS += $(STD_PERIPH_SRC)

# lwIP sources
SRCS += $(LWIP_SRC)

# Ethernet drive sources
SRCS += $(STD_ETH_SRC)

# FreeRTOS sources
SRCS += $(FREE_RTOS_SRC)

.PHONY: proj

all: proj

proj: $(PROJ_NAME).elf

$(PROJ_NAME).elf: $(SRCS)
	$(CC) $(CFLAGS) $^ -o $@
	$(OBJCOPY) -O ihex $(PROJ_NAME).elf $(PROJ_NAME).hex
	$(OBJCOPY) -O binary $(PROJ_NAME).elf $(PROJ_NAME).bin

clean:
	rm -f *.o $(PROJ_NAME).elf $(PROJ_NAME).hex $(PROJ_NAME).bin

# Flash the STM32
burn: proj
	$(STLINK)/st-flash write $(PROJ_NAME).bin 0x8000000
