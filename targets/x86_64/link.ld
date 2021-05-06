ENTRY(_start)

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
