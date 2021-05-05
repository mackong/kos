.code16
.org 0

.text

.global _start
    .type _start, @function
_start:
    cli

    /* setup segment */
    mov %cs, %ax
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %fs
    mov %ax, %gs
    mov %ax, %ss

    /* place stack pointer in middle of free memory area */
    movw $0x8000, %bp
    mov %bp, %sp

    # save drive number
    mov %dl, drive_num

    sti

    movw $welcome_str, %si
    call print

    call load_kernel

    /* video mode: 320x200 @ 16 colors */
    ;; movb $0x00, %ah
    ;; movb $0x13, %al
    ;; int $0x10

    call switch_to_pm

    jmp .  # Never be executed

welcome_str:
    .asciz "Welcome to MACKONG's OS!\n"
drive_num:
    .word 0x0000

.include "print.S"
.include "loader.S"
.include "gdt.S"
.include "idt.S"
.include "pm.S"
.include "entry32.S"

/* MBR boot signature */
.fill 510 - (. - _start), 1, 0
.word 0xaa55
