#ifndef SCREEN_H
#define SCREEN_H

#include <stdint.h>
#include <stddef.h>

enum {
        SCREEN_COLOR_BLACK = 0,
        SCREEN_COLOR_BLUE = 1,
        SCREEN_COLOR_GREEN = 2,
        SCREEN_COLOR_CYAN = 3,
        SCREEN_COLOR_RED = 4,
        SCREEN_COLOR_MAGENTA = 5,
        SCREEN_COLOR_BROWN = 6,
        SCREEN_COLOR_LIGHT_GRAY = 7,
        SCREEN_COLOR_DARK_GRAY = 8,
        SCREEN_COLOR_LIGHT_BLUE = 9,
        SCREEN_COLOR_LIGHT_GREEN = 10,
        SCREEN_COLOR_LIGHT_CYAN = 11,
        SCREEN_COLOR_LIGHT_RED = 12,
        SCREEN_COLOR_PINK = 13,
        SCREEN_COLOR_YELLOW = 14,
        SCREEN_COLOR_WHITE = 15,
};

void screen_init();
void screen_clear();
void screen_set_color(uint8_t fg, uint8_t bg);
void screen_write(const char *s);
void screen_write_char(char c);

#endif /* SCREEN_H */
