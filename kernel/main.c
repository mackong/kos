void _main() {
        unsigned short *video_memory = (unsigned short *) 0xb8000;
        *video_memory = 'X' | (0x0f << 8);
        for (;;) {
        }
}
