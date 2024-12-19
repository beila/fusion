main:
    nim c --os:any --out:build/main.exe main.nim
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
