#ifndef ARCH_UTIL_H
#define ARCH_UTIL_H

#include "arch/x86_64/screen.h"

#define cli() __asm__ volatile("cli")
#define sti() __asm__ volatile("sti")

static inline void panic(const char *err) {
        if (err != NULL) {
                screen_set_color(SCREEN_COLOR_WHITE, SCREEN_COLOR_BLUE);
                screen_write(err);
        }

        __asm__ volatile("hlt");
}

#endif /* ARCH_UTIL_H */
