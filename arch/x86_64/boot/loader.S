/* Loader kernel */
load_kernel:
    movw $20, %cx
    movb drive_num, %dl
    movw $disk_packet, %si
    movw $0x1000, segment
    movw $1, sector
sector_loop:
    movb $0x42, %ah
    int $0x13
    jc disk_error

    addw $64, sector
    addw $0x8000, offset
    jnc sector_same_segment

    /* increment segment, reset offset if on different segment */
    addw $0x1000, segment
    movw $0x0000, offset
sector_same_segment:
    /* decrements %cx and loops if nonzero */
    loop sector_loop

loader_kernel_done:
    ret

disk_error:
    movw $disk_error_str, %si
    call print

disk_error_str:
    .asciz "DISK ERROR\n"

disk_packet:
    .byte 0x10
    .byte 0x00
num_sectors:
    .word 0x0040
offset:
    .word 0x0000
segment:
    .word 0x0000
sector:
    .quad 0x00000000
