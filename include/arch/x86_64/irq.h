#ifndef IRQ_H
#define IRQ_H

#include <stddef.h>

#include "arch/x86_64/interrupt.h"

void irq_install(size_t i, interrupt_handler handler);

void irq_init();

#endif /* IRQ_H */
