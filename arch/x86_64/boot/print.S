/* print string in %di:(%si) */
print:
    xorb %bh, %bh
    movb $0x0e, %ah

    lodsb

    cmpb $0, %al
    je print_done

    int $0x10
    jmp print

print_done:
    ret
