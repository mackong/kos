#ifndef KOS_UTIL_H
#define KOS_UTIL_H

// returns the highest set bit of x
// i.e. if x == 0xF, HIBIT(x) == 3 (4th index)
// WARNING: currently only works for up to 32-bit types
#define HIBIT(_x) (31 - __builtin_clz((_x)))

// returns the lowest set bit of x
#define LOBIT(_x) __extension__({ __typeof__(_x) __x = (_x); HIBIT(__x & -__x); })

// returns _v with _n-th bit = _x
#define BIT_SET(_v, _n, _x) __extension__({                     \
                        __typeof__(_v) __v = (_v);              \
                        (__v ^ ((-(_x) ^ __v) & (1 << (_n))));  \
                })

#endif /* KOS_UTIL_H */
