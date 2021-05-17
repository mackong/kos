#ifndef TIMER_H
#define TIMER_H

#include <stdint.h>

#define TIMER_TPS 363

void timer_init();
uint64_t timer_get();

#endif /* TIMER_H */
