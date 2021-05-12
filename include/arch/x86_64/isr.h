#ifndef ISR_H
#define ISR_H

#include <stddef.h>

#include "interrupt.h"

void isr_install(size_t i, interrupt_handler handler);

void isr_init();

#endif /* ISR_H */
