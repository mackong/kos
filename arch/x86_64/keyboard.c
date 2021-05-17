#include "arch/x86_64/keyboard.h"
#include "arch/x86_64/io.h"
#include "arch/x86_64/irq.h"
#include "arch/x86_64/uart.h"
#include "kos/util.h"

#define KEYBOARD_DATA_PORT   0x60
#define KEYBOARD_STATUS_PORT 0x64

#define KEY_MOD_EMPTY       0x0
#define KEY_MOD_ALT         (1 << 0)
#define KEY_MOD_CTRL        (1 << 1)
#define KEY_MOD_SHIFT       (1 << 2)
#define KEY_MOD_CAPS_LOCK   (1 << 3)
#define KEY_MOD_NUM_LOCK    (1 << 4)
#define KEY_MOD_SCROLL_LOCK (1 << 5)
#define KEY_MOD_E0ESC       (1 << 6)

#define KEY_NULL 0
#define KEY_ESC 27
#define KEY_BACKSPACE '\b'
#define KEY_TAB '\t'
#define KEY_ENTER '\n'
#define KEY_RETURN '\r'

#define KEY_INSERT 0x90
#define KEY_DELETE 0x91
#define KEY_HOME 0x92
#define KEY_END 0x93
#define KEY_PAGE_UP 0x94
#define KEY_PAGE_DOWN 0x95
#define KEY_LEFT 0x4B
#define KEY_UP 0x48
#define KEY_RIGHT 0x4D
#define KEY_DOWN 0x50

#define KEY_F1 0x80
#define KEY_F2 (KEY_F1 + 1)
#define KEY_F3 (KEY_F1 + 2)
#define KEY_F4 (KEY_F1 + 3)
#define KEY_F5 (KEY_F1 + 4)
#define KEY_F6 (KEY_F1 + 5)
#define KEY_F7 (KEY_F1 + 6)
#define KEY_F8 (KEY_F1 + 7)
#define KEY_F9 (KEY_F1 + 8)
#define KEY_F10 (KEY_F1 + 9)
#define KEY_F11 (KEY_F1 + 10)
#define KEY_F12 (KEY_F1 + 11)

#define KEY_LCTRL 0x1D
#define KEY_RCTRL 0x9D

#define KEY_LSHIFT 0x2A
#define KEY_RSHIFT 0x36

#define KEY_LALT 0x38
#define KEY_RALT 0xB8

#define KEY_CAPS_LOCK 0x3A
#define KEY_NUM_LOCK 0x45
#define KEY_SCROLL_LOCK 0x46

static uint8_t charcode[][128] = {
        {
                // Normal
                KEY_NULL, KEY_ESC, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0',
                '-', '=', KEY_BACKSPACE, KEY_TAB, 'q', 'w', 'e', 'r', 't', 'y', 'u',
                'i', 'o', 'p', '[', ']', KEY_ENTER, 0, 'a', 's', 'd', 'f', 'g', 'h',
                'j', 'k', 'l', ';', '\'', '`', 0, '\\', 'z', 'x', 'c', 'v', 'b', 'n',
                'm', ',', '.', '/', 0, 0, 0, ' ', 0, KEY_F1, KEY_F2, KEY_F3, KEY_F4,
                KEY_F5, KEY_F6, KEY_F7, KEY_F8, KEY_F9, KEY_F10, 0, 0, KEY_HOME, KEY_UP,
                KEY_PAGE_UP, '-', KEY_LEFT, '5', KEY_RIGHT, '+', KEY_END, KEY_DOWN,
                KEY_PAGE_DOWN, KEY_INSERT, KEY_DELETE, 0, 0, 0, KEY_F11, KEY_F12
        }, {
                // Shift
                KEY_NULL, KEY_ESC, '!', '@', '#', '$', '%', '^', '&', '*', '(', ')',
                '_', '+', KEY_BACKSPACE, KEY_TAB, 'Q', 'W', 'E', 'R', 'T', 'Y', 'U',
                'I', 'O', 'P', '{', '}', KEY_ENTER, 0, 'A', 'S', 'D', 'F', 'G', 'H',
                'J', 'K', 'L', ':', '\"', '~', 0, '|', 'Z', 'X', 'C', 'V', 'B', 'N',
                'M', '<', '>', '?', 0, 0, 0, ' ', 0, KEY_F1, KEY_F2, KEY_F3, KEY_F4,
                KEY_F5, KEY_F6, KEY_F7, KEY_F8, KEY_F9, KEY_F10, 0, 0, KEY_HOME, KEY_UP,
                KEY_PAGE_UP, '-', KEY_LEFT, '5', KEY_RIGHT, '+', KEY_END, KEY_DOWN,
                KEY_PAGE_DOWN, KEY_INSERT, KEY_DELETE, 0, 0, 0, KEY_F11, KEY_F12
        }
};

static uint8_t shiftcode[256] = {
        [KEY_LCTRL] = KEY_MOD_CTRL,
        [KEY_RCTRL] = KEY_MOD_CTRL,
        [KEY_LSHIFT] = KEY_MOD_SHIFT,
        [KEY_RSHIFT] = KEY_MOD_SHIFT,
        [KEY_LALT] = KEY_MOD_ALT,
        [KEY_RALT] = KEY_MOD_ALT,
};

static uint8_t togglecode[256] = {
        [KEY_CAPS_LOCK] = KEY_MOD_CAPS_LOCK,
	[KEY_NUM_LOCK] = KEY_MOD_NUM_LOCK,
	[KEY_SCROLL_LOCK] = KEY_MOD_SCROLL_LOCK,
};

static struct keyboard {
        uint8_t mods;
        bool chars[128];
} keyboard;

static uint8_t toggle_case(uint8_t c) {
        if ('a' <= c && c <= 'z') {
                c -= 'a' - 'A';
        } else if ('A' <= c && c <= 'Z') {
                c += 'a' - 'A';
        }
        return c;
}

static bool keyboard_has_data() {
        uint8_t status = inportb(KEYBOARD_STATUS_PORT);
        return (bool) (status & 0x01);
}

static void keyboard_handler(struct interrupt_context *ctx, int nr) {
        uint8_t data = 0;
        uint8_t c = 0;

        if (!keyboard_has_data()) {
                return;
        }

        data = inportb(KEYBOARD_DATA_PORT);

        if (data == 0xE0) {
                keyboard.mods |= KEY_MOD_E0ESC;
                return;
        }

        if (data & 0x80) { // Key released
                if (!(keyboard.mods & KEY_MOD_E0ESC)) {
                        data &= 0x7F;
                }
                keyboard.mods &= ~(shiftcode[data] | KEY_MOD_E0ESC);
                c = charcode[keyboard.mods & KEY_MOD_SHIFT][data];
                keyboard.chars[c] = false;
                return;
        }

        if (keyboard.mods & KEY_MOD_E0ESC) {
                data |= 0x80;
                keyboard.mods &= ~KEY_MOD_E0ESC;
        }

        keyboard.mods |= shiftcode[data];
        keyboard.mods ^= togglecode[data];
        c = charcode[keyboard.mods & KEY_MOD_SHIFT][data];
        if (keyboard.mods & KEY_MOD_CAPS_LOCK) {
                c = toggle_case(c);
        }
        keyboard.chars[c] = true;
}

void keyboard_init() {
        irq_install(1, keyboard_handler);
}

bool keyboard_char(uint8_t ch) {
        return keyboard.chars[ch];
}
