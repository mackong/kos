	.code64

	.section .text
	.align 8

	.macro ISR_NO_ERR index
	.global _isr\index
_isr\index:
	pushq $0
	pushq $\index
	jmp isr_common
	.endm

	.macro ISR_ERR index
	.global _isr\index
_isr\index:
	pushq $\index
	jmp isr_common
	.endm

	ISR_NO_ERR 0
	ISR_NO_ERR 1
	ISR_NO_ERR 2
	ISR_NO_ERR 3
	ISR_NO_ERR 4
	ISR_NO_ERR 5
	ISR_NO_ERR 6
	ISR_NO_ERR 7
	ISR_ERR 8
	ISR_NO_ERR 9
	ISR_ERR 10
	ISR_ERR 11
	ISR_ERR 12
	ISR_ERR 13
	ISR_ERR 14
	ISR_NO_ERR 15
	ISR_NO_ERR 16
	ISR_ERR 17
	ISR_NO_ERR 18
	ISR_NO_ERR 19
	ISR_NO_ERR 20
	ISR_NO_ERR 21
	ISR_NO_ERR 22
	ISR_NO_ERR 23
	ISR_NO_ERR 24
	ISR_NO_ERR 25
	ISR_NO_ERR 26
	ISR_NO_ERR 27
	ISR_NO_ERR 28
	ISR_NO_ERR 29
	ISR_ERR 30
	ISR_NO_ERR 31
	ISR_NO_ERR 32
	ISR_NO_ERR 33
	ISR_NO_ERR 34
	ISR_NO_ERR 35
	ISR_NO_ERR 36
	ISR_NO_ERR 37
	ISR_NO_ERR 38
	ISR_NO_ERR 39
	ISR_NO_ERR 40
	ISR_NO_ERR 41
	ISR_NO_ERR 42
	ISR_NO_ERR 43
	ISR_NO_ERR 44
	ISR_NO_ERR 45
	ISR_NO_ERR 46
	ISR_NO_ERR 47

	/* defined in isr.c */
	.extern isr_handler
	.type isr_handler, @function

isr_common:
	cld

	pushq %rsi
	movq 8(%rsp), %rsi  /* RSI = vector number */
	movq %rdi, 8(%rsp)
	pushq %rdx
	pushq %rcx
	pushq %rax
	pushq %r8
	pushq %r9
	pushq %r10
	pushq %r11
	pushq %rbx
	pushq %rbp
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15

	movq %rsp, %rdi  /* RDI = interrupt_context */
	call isr_handler

	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbp
	popq %rbx
	popq %r11
	popq %r10
	popq %r9
	popq %r8
	popq %rax
	popq %rcx
	popq %rdx
	popq %rsi
	popq %rdi
	addq $8, %rsp
	iretq
