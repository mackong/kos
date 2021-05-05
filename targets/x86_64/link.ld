ENTRY(_start)

SECTIONS
{
    . = 1M;

    .boot :
    {
        KEEP(*(.multiboot_header))
    }

    .text BLOCK(4K) : ALIGN(4K)
    {
        *(.text.prologue)
        *(.text)
    }
}
