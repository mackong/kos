#ifndef ISR_H
#define ISR_H

#include <stddef.h>

#include "interrupt.h"

void isr_init();
void isr_install(size_t i, interrupt_handler handler);

#endif /* ISR_H */
