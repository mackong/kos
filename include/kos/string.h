#ifndef STRING_H
#define STRING_H

#include <stdint.h>
#include <stddef.h>

static inline void *memset(void *s, int c, size_t n) {
    uint8_t *ps = s;
    while (n--) {
        *ps++ = c;
    }
    return s;
}

#endif /* STRING_H */
