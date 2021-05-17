#ifndef IDT_H
#define IDT_H

#include <stdint.h>

typedef void (* idt_handler) ();

void idt_init();
void idt_set(uint8_t index, idt_handler base, uint16_t selector, uint8_t flags);

#endif /* IDT_H */
