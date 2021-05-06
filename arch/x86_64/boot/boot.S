.section .multiboot_header

multiboot_header:
	/* magic number */
	.long 0xe85250d6
	/* ISA: i386 */
	.long 0
	/* Header length */
	.long multiboot_header_end - multiboot_header
	/* checksum */
	.long -(0xe85250d6 + 0 + (multiboot_header_end - multiboot_header))
	/* tag */
	.short 0
	.short 0
	.long 8
multiboot_header_end:

	.code32
	.section .text

	.globl _start32
	.type _start32, @function
_start32:
	jmp multiboot_entry

	.align 8

multiboot_entry:
	mov $stack_top, %esp

	call check_multiboot
	call check_cpuid
	call check_long_mode

	call setup_page_tables
	call enable_paging

	lgdt gdtp
	/* 0x08 is the first gdt entry */
	/* see https://stackoverflow.com/questions/23978486/far-jump-in-gdt-in-bootloader */
	ljmp $0x0008, $_start64

	cli  /* Should never here */
	hlt

check_multiboot:
	cmp $0x36d76289, %eax
	jne .no_multiboot
	ret
.no_multiboot:
	movb $'M', %al
	jmp error

check_cpuid:
	pushfl
	pop %eax
	mov %eax, %ecx
	xor $(1 << 21), %eax
	push %eax
	popfl
	pushfl
	pop %eax
	push %ecx
	popfl
	cmp %ecx, %eax
	je .no_cpuid
	ret
.no_cpuid:
	movb $'C', %al
	jmp error

check_long_mode:
	mov $0x80000000, %eax
	cpuid
	cmp $0x80000001, %eax
	jb .no_long_mode

	mov $0x80000001, %eax
	cpuid
	test $(1 << 29), %edx
	jz .no_long_mode

	ret
.no_long_mode:
	movb $'L', %al
	jmp error

error:
	/* print "ERR: X" where X is the error code */
	mov $0x4f524f45, 0xb8000
	mov $0x4f3a4f52, 0xb8004
	mov $0x4f204f20, 0xb8008
	movb %al, 0xb800a
	hlt

setup_page_tables:
	mov $page_table_l3, %eax
	or $0b11, %eax  /* present, writable */
	mov %eax, page_table_l4

	mov $page_table_l2, %eax
	orl $0b11, %eax  /* present, writable */
	mov %eax, page_table_l3

	mov $0, %ecx  /* counter */
.loop:

	mov $0x200000, %eax  /* 2MiB */
	mul %ecx
	or $0b10000011, %eax  /* present, writable, huge page */
	mov %eax, page_table_l2(, %ecx, 8)

	inc %ecx
	cmp $512, %ecx  /* checks if the whole table is mapped */
	jne .loop

	ret

enable_paging:
	/* pass page table location to cpu */
	mov page_table_l4, %eax
	mov %eax, %cr3

	/* enable PAE */
	mov %cr4, %eax
	or $(1 << 5), %eax
	mov %eax, %cr4

	/* enable long mode */
	mov $0xC0000080, %ecx
	rdmsr
	or $(1 << 8), %eax
	wrmsr

	/* enable paging */
	mov %cr0, %eax
	or $(1 << 31), %eax
	mov %eax, %cr0

	ret

	.section .bss
	.align 4096
page_table_l4:
	.fill 0x1000
page_table_l3:
	.fill 0x1000
page_table_l2:
	.fill 0x1000
stack_bottom:
	.fill 0x4000
stack_top:

	.section .rodata
gdtp:
	.short gdt_end - gdt_start - 1
	.quad gdt_start
gdt_start:
gdt_null_entry:
	.quad 0
gdt_kernel_code_entry:
	.quad (1 << 43) | (1 << 44) | (1 << 47) | (1 << 53)
gdt_end:


	/* code for long mode */
	.code64
	.section .text

	.extern kmain

	.globl _start64
	.type _start64, @function
_start64:
	movw $0, %ax
	movw %ax, %ss
	movw %ax, %ds
	movw %ax, %es
	movw %ax, %fs
	movw %ax, %gs

	call kmain
	hlt
