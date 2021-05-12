#include "arch/x86_64/isr.h"
#include "arch/x86_64/interrupt.h"
#include "arch/x86_64/idt.h"
#include "arch/x86_64/util.h"

extern void _isr0();
extern void _isr1();
extern void _isr2();
extern void _isr3();
extern void _isr4();
extern void _isr5();
extern void _isr6();
extern void _isr7();
extern void _isr8();
extern void _isr9();
extern void _isr10();
extern void _isr11();
extern void _isr12();
extern void _isr13();
extern void _isr14();
extern void _isr15();
extern void _isr16();
extern void _isr17();
extern void _isr18();
extern void _isr19();
extern void _isr20();
extern void _isr21();
extern void _isr22();
extern void _isr23();
extern void _isr24();
extern void _isr25();
extern void _isr26();
extern void _isr27();
extern void _isr28();
extern void _isr29();
extern void _isr30();
extern void _isr31();
extern void _isr32();
extern void _isr33();
extern void _isr34();
extern void _isr35();
extern void _isr36();
extern void _isr37();
extern void _isr38();
extern void _isr39();
extern void _isr40();
extern void _isr41();
extern void _isr42();
extern void _isr43();
extern void _isr44();
extern void _isr45();
extern void _isr46();
extern void _isr47();

static idt_handler stubs[NUM_ISRS] = {
        _isr0,
        _isr1,
        _isr2,
        _isr3,
        _isr4,
        _isr5,
        _isr6,
        _isr7,
        _isr8,
        _isr9,
        _isr10,
        _isr11,
        _isr12,
        _isr13,
        _isr14,
        _isr15,
        _isr16,
        _isr17,
        _isr18,
        _isr19,
        _isr20,
        _isr21,
        _isr22,
        _isr23,
        _isr24,
        _isr25,
        _isr26,
        _isr27,
        _isr28,
        _isr29,
        _isr30,
        _isr31,
        _isr32,
        _isr33,
        _isr34,
        _isr35,
        _isr36,
        _isr37,
        _isr38,
        _isr39,
        _isr40,
        _isr41,
        _isr42,
        _isr43,
        _isr44,
        _isr45,
        _isr46,
        _isr47,
};

static const char *exceptions[NUM_EXCEPTIONS] = {
        "Divide by zero",
        "Debug",
        "NMI",
        "Breakpoint",
        "Overflow",
        "OOB",
        "Invalid opcode",
        "No coprocessor",
        "Double fault",
        "Coprocessor segment overrun",
        "Bad TSS",
        "Segment not present",
        "Stack fault",
        "General protection fault",
        "Page fault",
        "Unrecognized interrupt",
        "Coprocessor fault",
        "Alignment check",
        "Machine check",
        "RESERVED",
        "RESERVED",
        "RESERVED",
        "RESERVED",
        "RESERVED",
        "RESERVED",
        "RESERVED",
        "RESERVED",
        "RESERVED",
        "RESERVED",
        "RESERVED",
};

static interrupt_handler handlers[NUM_ISRS] = { NULL };

void isr_install(size_t i, interrupt_handler handler) {
        handlers[i] = handler;
}

void isr_handler(struct interrupt_context *ctx, int nr) {
        if (handlers[nr]) {
                handlers[nr](ctx, nr);
        }
}

static void exception_handler(struct interrupt_context *ctx, int nr) {
        panic(exceptions[nr]);
}

void isr_init() {
        for (size_t i = 0; i < NUM_ISRS; i++) {
                idt_set(i, stubs[i], 0x08, 0x8E);
        }

        for (size_t i = 0; i < NUM_EXCEPTIONS; i++) {
                isr_install(i, exception_handler);
        }
}
