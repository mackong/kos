.code64

.section .text

.extern kmain

.globl long_mode_start
	.type long_mode_start, @function
long_mode_start:
	mov $0, %ax
	mov %ax, %ss
	mov %ax, %ds
	mov %ax, %es
	mov %ax, %fs
	mov %ax, %gs

	call kmain
	hlt
