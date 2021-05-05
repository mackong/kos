CC=gcc -elf_i386
AS=as --32
LD=ld -m elf_i386
GDB=gdb
QEMU=qemu-system-x86_64

CCFLAGS=-m32 -std=c11 -g -Wall -Wextra -Wpedantic -Wstrict-aliasing -Wno-pointer-arith -Wno-unused-parameter
CCFLAGS+=-nostdlib -nostdinc -ffreestanding -fno-pie -fno-stack-protector
CCFLAGS+=-fno-builtin-function -fno-builtin
ASFLAGS=
LDFLAGS=

BOOT_SRCS_DIR=arch/x86_64/boot
BOOT_SRCS=$(BOOT_SRCS_DIR)/boot.S
BOOT_OBJS=$(BOOT_SRCS:.S=.o)

KERNEL_C_SRCS=$(wildcard kernel/*.c)
KERNEL_S_SRCS=$(wildcard kernel/*.S)
KERNEL_OBJS=$(KERNEL_C_SRCS:.c=.o) $(KERNEL_S_SRCS:.S=.o)

BUILD=./build
BOOT_BIN=$(BUILD)/boot.bin
KERNEL_BIN=$(BUILD)/kernel.bin
KERNEL_ELF=$(BUILD)/kernel.elf
KERNEL_ISO=$(BUILD)/kernel.iso

all: dirs boot kernel iso

clean:
	rm -f ./**/*.o
	rm -rf $(BUILD)

%.o: %.c
	$(CC) -o $@ -c $< $(CCFLAGS)
%.o: %.S
	$(AS) -o $@ -c $< $(ASFLAGS) -I$(BOOT_SRCS_DIR)

dirs:
	mkdir -p $(BUILD)

boot: $(BOOT_OBJS)
	$(LD) -o $(BOOT_BIN) $^ -Ttext 0x7c00 --oformat=binary

kernel: $(KERNEL_OBJS)
	$(LD) -o $(KERNEL_BIN) $^ $(LDFLAGS) -Tkernel/link.ld
	$(LD) -o $(KERNEL_ELF) $^ $(LDFLAGS) -Ttools/debug.ld

iso: $(BOOT_BIN) $(KERNEL_BIN)
	dd if=/dev/zero of=$(KERNEL_ISO) bs=512 count=2880
	dd if=$(BOOT_BIN) of=$(KERNEL_ISO) conv=notrunc bs=512 seek=0 count=1
	dd if=$(KERNEL_BIN) of=$(KERNEL_ISO) conv=notrunc bs=512 seek=1 count=2048

run:
	$(QEMU) \
		-display sdl \
		-drive format=raw,file=$(KERNEL_ISO) \
		-d cpu_reset \
		-monitor stdio \
		-audiodev sdl,id=sdl,out.frequency=48000,out.channels=2,out.format=s32 \
		-device sb16,audiodev=sdl

debug:
	$(QEMU) \
		-display sdl \
		-drive format=raw,file=$(KERNEL_ISO) \
		-d cpu_reset \
		-monitor stdio \
		-audiodev sdl,id=sdl,out.frequency=48000,out.channels=2,out.format=s32 \
		-device sb16,audiodev=sdl -s -S

gdb:
	$(GDB) \
		-iex "target remote :1234" \
		-iex "symbol-file $(KERNEL_ELF)"
