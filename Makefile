CC=gcc
AS=as
LD=ld
GDB=gdb
QEMU=qemu-system-x86_64

CCFLAGS=-std=c11 -g -Wall -Wextra -Wpedantic -Wstrict-aliasing -Wno-pointer-arith -Wno-unused-parameter
CCFLAGS+=-nostdlib -ffreestanding -fno-pie -fno-stack-protector
CCFLAGS+=-fno-builtin-function -fno-builtin
ASFLAGS=-g
LDFLAGS=

ARCH_SRCS_DIR=arch/x86_64
ARCH_S_SRCS=$(wildcard $(ARCH_SRCS_DIR)/boot/*.S)
ARCH_C_SRCS=$(wildcard $(ARCH_SRCS_DIR)/*.c)
ARCH_OBJS=$(ARCH_S_SRCS:.S=.o) $(ARCH_C_SRCS:.c=.o)

KERNEL_C_SRCS=$(wildcard kernel/*.c)
KERNEL_S_SRCS=$(wildcard kernel/*.S)
KERNEL_OBJS=$(KERNEL_C_SRCS:.c=.o) $(KERNEL_S_SRCS:.S=.o)

INCLUDE_DIR=include

TARGETS=targets/x86_64
KERNEL_BIN=$(TARGETS)/iso/boot/kernel.bin
KERNEL_ISO=$(TARGETS)/kernel.iso
KERNEL_LINK=$(TARGETS)/link.ld
GRUB_SRC=$(TARGETS)/iso

all: kernel_iso

clean:
	find . -name "*.o" | xargs rm -f
	rm -f $(KERNEL_BIN) $(KERNEL_ISO)

%.o: %.c
	$(CC) -o $@ -c $< $(CCFLAGS) -I$(INCLUDE_DIR)
%.o: %.S
	$(AS) -o $@ -c $< $(ASFLAGS)

kernel_bin: $(ARCH_OBJS) $(KERNEL_OBJS)
	$(LD) -o $(KERNEL_BIN) $^ -T $(KERNEL_LINK)

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
