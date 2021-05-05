CC=gcc
AS=as
LD=ld
GDB=gdb
QEMU=qemu-system-x86_64

CCFLAGS=-std=c11 -g -Wall -Wextra -Wpedantic -Wstrict-aliasing -Wno-pointer-arith -Wno-unused-parameter
CCFLAGS+=-nostdlib -nostdinc -ffreestanding -fno-pie -fno-stack-protector
CCFLAGS+=-fno-builtin-function -fno-builtin
ASFLAGS=-g
LDFLAGS=

BOOT_SRCS_DIR=arch/x86_64/boot
BOOT_SRCS=$(wildcard $(BOOT_SRCS_DIR)/*.S)
BOOT_OBJS=$(BOOT_SRCS:.S=.o)

KERNEL_C_SRCS=$(wildcard kernel/*.c)
KERNEL_S_SRCS=$(wildcard kernel/*.S)
KERNEL_OBJS=$(KERNEL_C_SRCS:.c=.o) $(KERNEL_S_SRCS:.S=.o)

TARGETS=./targets/x86_64
KERNEL_BIN=$(TARGETS)/iso/boot/kernel.bin
KERNEL_ISO=$(TARGETS)/kernel.iso
KERNEL_LINK=$(TARGETS)/link.ld
GRUB_SRC=$(TARGETS)/iso

all: kernel_iso

clean:
	find . -name "*.o" | xargs rm -f
	rm -f $(KERNEL_BIN) $(KERNEL_ISO)

%.o: %.c
	$(CC) -o $@ -c $< $(CCFLAGS)
%.o: %.S
	$(AS) -o $@ -c $< $(ASFLAGS) -I$(BOOT_SRCS_DIR)

kernel_bin: $(BOOT_OBJS)
	$(LD) -o $(KERNEL_BIN) $^ -T$(KERNEL_LINK)

kernel_iso: kernel_bin
	grub-mkrescue -d /usr/lib/grub/i386-pc -o $(KERNEL_ISO) $(GRUB_SRC)

run:
	$(QEMU) \
		-display sdl \
		-cdrom $(KERNEL_ISO) \
		-d cpu_reset \
		-monitor stdio \
		-audiodev sdl,id=sdl,out.frequency=48000,out.channels=2,out.format=s32 \
		-device sb16,audiodev=sdl

debug:
	$(QEMU) \
		-display sdl \
		-cdrom $(KERNEL_ISO) \
		-d cpu_reset \
		-monitor stdio \
		-audiodev sdl,id=sdl,out.frequency=48000,out.channels=2,out.format=s32 \
		-device sb16,audiodev=sdl -s -S

gdb:
	$(GDB) \
		-iex "target remote :1234" \
		-iex "symbol-file $(KERNEL_BIN)"
