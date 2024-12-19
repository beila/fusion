import malloc
import libc

type
    EfiStatus = uint
    EfiHandle = pointer
    EfiSystemTable = object

const
    EfiSuccess = 0

proc NimMain() {.importc.}

proc EfiMain(imgHandle: EfiHandle, sysTable: ptr EfiSystemTable): EfiStatus {.exportc.} =
    NimMain()
    return EfiSuccess
