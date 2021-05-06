.code32

.section .text.prologue

.extern long_mode_start

.globl _start
	.type _start, @function
_start:
	mov $stack_top, %esp

	call check_multiboot
	call check_cpuid
	call check_long_mode

	call setup_page_tables
	call enable_paging

	lgdt gdtp
	jmp long_mode_start

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
	movl $0x4f524f45, 0xb8000
	movl $0x4f3a4f52, 0xb8004
	movl $0x4f204f20, 0xb8008
	movb %al, 0xb800a
	hlt

setup_page_tables:
	mov $page_table_l3, %eax
	or $0b11, %eax  /* present, writable */
	mov %eax, page_table_l4

	mov $page_table_l2, %eax
	or $0b11, %eax  /* present, writable */
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
gdt_start:
	.quad 0
gdt_code_segment:
	.quad (1 << 43) | (1 << 44) | (1 << 47) | (1 << 53)
gdtp:
	.short . - gdt_start - 1
	.quad gdt_start
