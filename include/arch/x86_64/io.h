#ifndef IO_H
#define IO_H

#include <stdint.h>

static inline uint8_t inportb(uint16_t port) {
    uint8_t r;
    __asm__ volatile ("inb %1, %0" : "=a" (r) : "dN" (port));
    return r;
}

static inline void outportb(uint16_t port, uint8_t data) {
    __asm__ volatile ("outb %1, %0" : : "dN" (port), "a" (data));
}

#endif /* IO_H */
