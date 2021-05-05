.code32

.section .text.prologue
.global _start
	.type _start, @function
_start:
	call _main
	jmp .
