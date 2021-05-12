#include "arch/x86_64/idt.h"
#include "arch/x86_64/isr.h"
#include "arch/x86_64/irq.h"
#include "arch/x86_64/screen.h"
#include "arch/x86_64/timer.h"

void kmain() {
        idt_init();
        isr_init();
        irq_init();
        screen_init();
        timer_init();

        screen_clear();
        screen_set_color(SCREEN_COLOR_BLUE, SCREEN_COLOR_GREEN);
        screen_write("Welcome to kos!\n");
}
