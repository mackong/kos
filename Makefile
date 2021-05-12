CC=gcc
LD=ld
GDB=gdb
QEMU=qemu-system-x86_64

CCFLAGS=-std=c11 -g -Wall -Wextra -Wpedantic -Wstrict-aliasing -Wno-pointer-arith -Wno-unused-parameter
CCFLAGS+=-nostdlib -ffreestanding -fno-pie -fno-stack-protector
CCFLAGS+=-fno-builtin-function -fno-builtin
CCFLAGS+=-Iinclude
ASFLAGS=-g
LDFLAGS=

ARCH_SRCS_DIR=arch/x86_64
ARCH_BOOT_SRCS=$(wildcard $(ARCH_SRCS_DIR)/boot/*.S)
ARCH_C_SRCS=$(wildcard $(ARCH_SRCS_DIR)/*.c)
ARCH_S_SRCS=$(wildcard $(ARCH_SRCS_DIR)/*.S)
ARCH_OBJS=$(ARCH_BOOT_SRCS:.S=.o) $(ARCH_C_SRCS:.c=.o) $(ARCH_S_SRCS:.S=.o)

KERNEL_C_SRCS=$(wildcard kernel/*.c)
KERNEL_S_SRCS=$(wildcard kernel/*.S)
KERNEL_OBJS=$(KERNEL_C_SRCS:.c=.o) $(KERNEL_S_SRCS:.S=.o)

TARGETS=targets/x86_64
KERNEL_BIN=$(TARGETS)/iso/boot/kernel.bin
KERNEL_ISO=$(TARGETS)/kernel.iso
KERNEL_LINK=$(TARGETS)/link.ld
GRUB_SRC=$(TARGETS)/iso

all: $(KERNEL_ISO)

clean:
	find . -name "*.o" | xargs rm -f
	rm -f $(KERNEL_BIN) $(KERNEL_ISO)

%.o: %.c
	$(CC) -o $@ -c $< $(CCFLAGS)
%.o: %.S
	$(CC) -o $@ -c $< $(ASFLAGS)

$(KERNEL_BIN): $(ARCH_OBJS) $(KERNEL_OBJS)
	$(LD) -o $@ $^ -T $(KERNEL_LINK)

$(KERNEL_ISO): $(KERNEL_BIN)
	grub-mkrescue -d /usr/lib/grub/i386-pc -o $@ $(GRUB_SRC)

run: $(KERNEL_ISO)
	$(QEMU) \
		-display sdl \
		-cdrom $< \
		-d cpu_reset \
		-monitor stdio \
		-audiodev sdl,id=sdl,out.frequency=48000,out.channels=2,out.format=s32 \
		-device sb16,audiodev=sdl

debug: $(KERNEL_ISO)
	$(QEMU) \
		-display sdl \
		-cdrom $< \
		-d cpu_reset \
		-monitor stdio \
		-audiodev sdl,id=sdl,out.frequency=48000,out.channels=2,out.format=s32 \
		-device sb16,audiodev=sdl \
		-s -S

gdb: $(KERNEL_BIN)
	$(GDB) \
		-iex "target remote :1234" \
		-iex "symbol-file $(KERNEL_BIN)"
