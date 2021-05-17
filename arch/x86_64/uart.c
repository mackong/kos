#include <stdbool.h>

#include "arch/x86_64/uart.h"
#include "arch/x86_64/io.h"

#define SERIAL_COM1_BASE                0x3F8
#define SERIAL_DATA_PORT(base)          (base)
#define SERIAL_FIFO_COMMAND_PORT(base)  (base + 2)
#define SERIAL_LINE_COMMAND_PORT(base)  (base + 3)
#define SERIAL_MODEM_COMMAND_PORT(base) (base + 4)
#define SERIAL_LINE_STATUS_PORT(base)   (base + 5)

static bool serial_is_transmit_fifo_empty(unsigned int com)
{
        return (bool) (inportb(SERIAL_LINE_STATUS_PORT(com)) & 0x20);
}

void uart_init() {
        uint16_t base = SERIAL_COM1_BASE;

        outportb(SERIAL_LINE_COMMAND_PORT(base), 0x80);
        outportb(SERIAL_DATA_PORT(base), 115200/9600);
        outportb(SERIAL_FIFO_COMMAND_PORT(base), 0);

        outportb(SERIAL_LINE_COMMAND_PORT(base), 3);
        outportb(SERIAL_FIFO_COMMAND_PORT(base), 0);
}

void uart_write(const char *s) {
        char c;

        while ((c = *s) != '\0') {
                uart_write_char(c);
                s++;
        }
}

void uart_write_char(char c) {
        uint16_t base = SERIAL_COM1_BASE;

        for (;;) {
                if (serial_is_transmit_fifo_empty(base)) {
                        break;
                }
	}

        outportb(base, (uint8_t) c);
}
