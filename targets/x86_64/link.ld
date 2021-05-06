ENTRY(_start32)

SECTIONS
{
	. = 1M;

	.text :
	{
		*(.multiboot_header)
		*(.text.prologue)
		*(.text)
	}

	.bss :
	{
		*(.bss)
	}

	.rodata :
	{
		*(.rodata)
	}

	end = .;
}
