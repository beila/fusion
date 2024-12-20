{.used.}

import uefi

type
    const_pointer {.importc: "const void *".} = pointer

proc fwrite*(buf: const_pointer, size: csize_t, count: csize_t, stream: File): csize_t {.exportc.} =
    let output = $cast[cstring](buf)
    consoleOut(output)
    return count

proc fflush*(stream: File): cint {.exportc.} =
    return 0.cint

var
    stdout* {.exportc.}: File
    stderr* {.exportc.}: File

proc exit*(status: cint) {.exportc, asmNoStackFrame.} =
    asm """
    .loop:
        cli
        hlt
        jmp .loop
    """
