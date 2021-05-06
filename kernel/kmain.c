#include "screen.h"

void kmain() {
        screen_clear();
        screen_set_color(SCREEN_COLOR_BLUE, SCREEN_COLOR_GREEN);
        screen_print_str("Welcome to kos!\n");
}
