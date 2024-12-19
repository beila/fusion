bootx64:
    nim c --os:any --passl:"-Wl,-entry:EfiMain" --out:build/bootx64.efi src/bootx64.nim
    ls -l build/bootx64.efi
    file build/bootx64.efi

main:
    nim c --os:any --passl:"-Wl,-entry:main" --out:build/main.exe src/main.nim
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
