#include "arch/x86_64/irq.h"
#include "arch/x86_64/isr.h"
#include "arch/x86_64/io.h"
#include "arch/x86_64/util.h"

#define PIC1 0x20
#define PIC1_OFFSET 0x20
#define PIC1_DATA (PIC1 + 1)

#define PIC2 0xA0
#define PIC2_OFFSET 0x28
#define PIC2_DATA (PIC2 + 1)

#define PIC_EOI 0x20
#define PIC_MODE_8086 0x01
#define ICW1_ICW4 0x01
#define ICW1_INIT 0x10

#define PIC_WAIT() do {                         \
                asm ("jmp 1f\n\t"               \
                     "1:\n\t"                   \
                     "    jmp 2f\n\t"           \
                     "2:");                     \
        } while (0)

static interrupt_handler handlers[NUM_EXCEPTIONS] = { NULL };

static void stub(struct interrupt_context *ctx, int nr) {
        uint16_t port = 0;

        if (nr >= NUM_EXCEPTIONS && nr < NUM_ISRS) {
                if (handlers[nr - NUM_EXCEPTIONS]) {
                        handlers[nr - NUM_EXCEPTIONS](ctx, nr);
                }
        }

        // send EOI
        port = nr < 0x40 ? PIC1 : PIC2;
        outportb(port, PIC_EOI);
}

static void irq_remap() {
        uint8_t mask1 = inportb(PIC1_DATA);
        uint8_t mask2 = inportb(PIC2_DATA);

        outportb(PIC1, ICW1_INIT | ICW1_ICW4);
        outportb(PIC2, ICW1_INIT | ICW1_ICW4);
        outportb(PIC1_DATA, PIC1_OFFSET);
        outportb(PIC2_DATA, PIC2_OFFSET);
        outportb(PIC1_DATA, 0x04); // PIC2 at IRQ2
        outportb(PIC2_DATA, 0x02); // Cascade indentity
        outportb(PIC1_DATA, PIC_MODE_8086);
        outportb(PIC1_DATA, PIC_MODE_8086);
        outportb(PIC1_DATA, mask1);
        outportb(PIC2_DATA, mask2);
}

static void irq_set_mask(size_t i) {
    uint16_t port = i < 8 ? PIC1_DATA : PIC2_DATA;
    uint8_t value = inportb(port) | (1 << i);
    outportb(port, value);
}

static void irq_clear_mask(size_t i) {
    uint16_t port = i < 8 ? PIC1_DATA : PIC2_DATA;
    uint8_t value = inportb(port) & ~(1 << i);
    outportb(port, value);
}

void irq_install(size_t i, interrupt_handler handler) {
        cli();
        handlers[i] = handler;
        irq_clear_mask(i);
        sti();
}

void irq_init() {
        irq_remap();

        for (size_t i = NUM_EXCEPTIONS; i < NUM_ISRS; i++) {
                isr_install(i, stub);
        }
}
