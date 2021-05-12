#include "arch/x86_64/timer.h"
#include "arch/x86_64/io.h"
#include "arch/x86_64/isr.h"
#include "arch/x86_64/irq.h"

#define PIT_A 0x40
#define PIT_B 0x41
#define PIT_C 0x42
#define PIT_CONTROL 0x43

#define PIT_MASK 0xFF
#define PIT_SET 0x36

#define PIT_HZ 1193181

static uint64_t ticks = 0;

static void timer_handler(struct interrupt_context *ctx, int nr) {
        ticks++;
}

static void timer_set(int tps) {
        outportb(PIT_CONTROL, PIT_SET);

        uint16_t d = (uint16_t) (PIT_HZ / tps);
        outportb(PIT_A, d & PIT_MASK);
        outportb(PIT_A, (d >> 8) & PIT_MASK);
}

uint64_t timer_get() {
        return ticks;
}

void timer_init() {
        timer_set(TIMER_TPS);
        irq_install(0, timer_handler);
}
