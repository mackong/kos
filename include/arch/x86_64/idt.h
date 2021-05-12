#ifndef IDT_H
#define IDT_H

#include <stdint.h>

typedef void (* idt_handler) ();

void idt_set(uint8_t index, idt_handler base, uint16_t selector, uint8_t flags);

void idt_init();

#endif /* IDT_H */
