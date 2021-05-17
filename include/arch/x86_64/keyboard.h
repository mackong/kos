#ifndef KEYBOARD_H
#define KEYBOARD_H

#include <stdint.h>
#include <stdbool.h>

void keyboard_init();
bool keyboard_char(uint8_t ch);

#endif /* KEYBOARD_H */
