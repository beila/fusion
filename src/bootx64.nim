import malloc
import libc
import uefi

proc NimMain() {.importc.}

proc EfiMain(imgHandle: EfiHandle, sysTable: ptr EfiSystemTable): EfiStatus {.exportc.} =
    NimMain()
    uefi.sysTable = sysTable

    consoleClear()
    echo "Hello, world!"

    quit()
