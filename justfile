nimflags := "--os:any"

run: bootloader kernel
    mkdir -p diskimg/efi/boot
    mkdir -p diskimg/efi/fusion
    cp build/bootx64.efi diskimg/efi/boot/bootx64.efi
    cp build/kernel.bin diskimg/efi/fusion/kernel.bin
    qemu-system-x86_64 \
        -drive if=pflash,format=raw,file=ovmf/OVMF_CODE.fd,readonly=on \
        -drive if=pflash,format=raw,file=ovmf/OVMF_VARS.fd \
        -drive format=raw,file=fat:rw:diskimg \
        -machine q35 \
        -net none

bootloader:
    nim c {{ nimflags }} --out:build/bootx64.efi src/boot/bootx64.nim
    ls -l build/bootx64.efi
    file build/bootx64.efi

kernel:
    nim c {{ nimflags }} --out:build/kernel.bin src/kernel/main.nim
    ls -l build/kernel.bin
    file build/kernel.bin
    llvm-objdump --section-headers build/@mmain.nim.c.o
    head -n 10 build/kernel.map | grep --color=always --context=9999 "KernelMain"
    wc -c build/kernel.bin

kernel_elf:
    nim c {{ nimflags }} --passl:"--oformat=elf" --passl:"-Map=build/kernel.elf.map" --out:build/kernel.elf.bin src/kernel/main.nim
    ls -l build/kernel.elf.bin
    file build/kernel.elf.bin
    llvm-objdump --section-headers build/@mmain.nim.c.o
    llvm-readelf --headers build/kernel.elf.bin | grep --color=always --context=9999 "Entry point address\|\.data\|\.bss"
    head -n 10 build/kernel.elf.map | grep --color=always --context=9999 "KernelMain"

main:
    nim c {{ nimflags }} --passl:"-Wl,-entry:main" --out:build/main.exe src/main.nim
    ls -l build/main.exe
    file build/main.exe

c_main_exe: c_main_o
    clang \
        -target x86_64-unknown-windows \
        -fuse-ld=lld-link \
        -nostdlib \
        -Wl,-entry:main \
        -Wl,-subsystem:efi_application \
        -o build/main.exe \
        build/main.o
    ls -l build/main.exe
    file build/main.exe

c_main_o:
    mkdir -p build
    clang -c \
        -target x86_64-unknown-windows \
        -ffreestanding \
        -o build/main.o \
        main.c
    ls -l build/main.o
    file build/main.o

setup:
    brew install nim llvm lld qemu
    brew tap uenob/qemu-hvf
    brew install ovmf

    nim -v
    clang --version
    ld.lld --version
    qemu-system-x86_64 --version

    mkdir -p ovmf
    cp -f $(brew --prefix)/Cellar/ovmf/stable202102/share/OVMF/OvmfX64/* ovmf/
    chmod +w ovmf/OVMF_VARS.fd
