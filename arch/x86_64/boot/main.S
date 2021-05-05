.code32

.text

.globl _start
_start:
    movl $0x2f4b2f4f, 0xb8000
    hlt
