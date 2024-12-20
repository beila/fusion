import malloc
import libc
import uefi

proc NimMain() {.importc.}

proc UnhandledException*(e: ref Exception) =
    echo "Unhandled exception: " & e.msg & " [" & $e.name & "]"
    if e.trace.len > 0:
        echo "Stack trace:"
        echo getStackTrace(e)
    quit()

proc EfiMainInner(imgHandle: EfiHandle, sysTable: ptr EfiSystemTable): EfiStatus =
    uefi.sysTable = sysTable
    consoleClear()

    # force an IndexDefect exception
    let a = [1, 2, 3]
    let n = 5
    discard a[n]

proc EfiMain(imgHandle: EfiHandle, sysTable: ptr EfiSystemTable): EfiStatus {.exportc.} =
    NimMain()

    try:
        return EfiMainInner(imgHandle, sysTable)
    except Exception as e:
        UnhandledException(e)
