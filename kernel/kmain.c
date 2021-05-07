#include "screen.h"

void kmain() {
        screen_clear();
        screen_set_color(SCREEN_COLOR_BLUE, SCREEN_COLOR_GREEN);
        screen_write("Welcome to kos!\n");
}
