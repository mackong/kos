#include "screen.h"

#define N_COLS 80
#define N_ROWS 25

struct Char {
        uint8_t c;
        uint8_t color;
};

static struct Char *buffer = (struct Char *) 0xb8000;
static size_t col = 0;
static size_t row = 0;
static uint8_t screen_color = SCREEN_COLOR_WHITE | SCREEN_COLOR_BLACK << 4;

static void clear_row(size_t row) {
        struct Char empty = (struct Char) {
                .c = ' ',
                .color = screen_color,
        };

        for (size_t col = 0; col < N_COLS; col++) {
                buffer[col + N_COLS * row] = empty;
        }
}

static void screen_write_newline() {
        col = 0;

        if (row < N_ROWS - 1) {
                row++;
                return;
        }

        for (size_t row = 1; row < N_ROWS; row++) {
                for (size_t col = 0; col < N_COLS; col++) {
                        struct Char c = buffer[col + N_COLS * row];
                        buffer[col + N_COLS * (row - 1)] = c;
                }
        }

        clear_row(N_COLS - 1);
}

static void screen_write_char(const char c) {
        if (c == '\n') {
                screen_write_newline();
                return;
        }

        if (col > N_COLS) {
                screen_write_newline();
        }

        buffer[col + row * N_COLS] = (struct Char) {
                .c = (uint8_t) c,
                .color = screen_color,
        };

        col++;
}

void screen_clear() {
        for (size_t row = 0; row < N_ROWS; row++) {
                clear_row(row);
        }
}

void screen_set_color(uint8_t fg, uint8_t bg) {
        screen_color = fg | bg << 4;
}

void screen_write(const char *s) {
        char c;
        while ((c = *s++) != '\0') {
                screen_write_char(c);
        }
}
