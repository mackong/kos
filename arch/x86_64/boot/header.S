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
