#include "arch/x86_64/idt.h"

#include "kos/string.h"

struct idt_bits {
        uint16_t ist  : 3,
                 zero : 5,
                 type : 5,
                 dpl  : 2,
                 p    : 1;
} __attribute__((packed));

struct idt_entry {
        uint16_t offset_low;
        uint16_t selector;
        struct idt_bits bits;
        uint16_t offset_middle;
        uint32_t offset_high;
        uint32_t reversed;
} __attribute__((packed));

struct idt_pointer {
        uint16_t limit;
        uintptr_t base;
} __attribute__((packed));

static struct {
        struct idt_entry entries[256];
        struct idt_pointer pointer;
} idt;

static void idt_load(const struct idt_pointer *pointer) {
        __asm__ volatile("lidt %0"::"m" (*pointer));
}

void idt_set(uint8_t index, idt_handler base, uint16_t selector, uint8_t flags) {
        struct idt_bits bits = (struct idt_bits) {
                .type = flags | 0x60,
                .p = 1,
        };
        idt.entries[index] = (struct idt_entry) {
                .offset_low = (uint16_t) (uintptr_t) base,
                .selector = selector,
                .bits = bits,
                .offset_middle = (uint16_t) (((uintptr_t) base) >> 16),
                .offset_high = (uint32_t) (((uintptr_t) base) >> 32),
                .reversed = 0
        };
}

void idt_init() {
        idt.pointer.limit = sizeof(idt.entries) - 1;
        idt.pointer.base = (uintptr_t) &idt.entries[0];
        memset(&idt.entries[0], 0, sizeof(idt.entries));
        idt_load(&idt.pointer);
}
