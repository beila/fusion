import common/malloc
import common/libc
import common/uefi

proc NimMain() {.importc.}

proc UnhandledException*(e: ref Exception) =
    echo "Unhandled exception: " & e.msg & " [" & $e.name & "]"
    if e.trace.len > 0:
        echo "Stack trace:"
        echo getStackTrace(e)
    quit()

proc EfiMainInnerPrintStacktrace(imgHandle: EfiHandle, sysTable: ptr EfiSystemTable): EfiStatus =
    uefi.sysTable = sysTable
    consoleClear()

    # force an IndexDefect exception
    let a = [1, 2, 3]
    let n = 5
    discard a[n]

proc checkStatus*(status: EfiStatus) =
    if status != EfiSuccess:
        consoleOut " [failed, status = {status:#x}]"
        quit()
    consoleOut " [success]\r\n"

proc EfiMainInner(imgHandle: EfiHandle, sysTable: ptr EfiSystemTable): EfiStatus =
    uefi.sysTable = sysTable
    consoleClear()

    echo "Fusion OS Bootloader"

    # get the LoadedImage protocol from the image handle
    var loadedImage: ptr EfiLoadedImageProtocol

    consoleOut "boot: Acquiring LoadedImage protocol"
    checkStatus uefi.sysTable.bootServices.handleProtocol(
        imgHandle, EfiLoadedImageProtocolGuid, cast[ptr pointer](addr loadedImage)
    )

    var fileSystem: ptr EfiSimpleFileSystemProtocol

    consoleOut "boot: Acquiring SimpleFileSystem protocol"
    checkStatus uefi.sysTable.bootServices.handleProtocol(
        loadedImage.deviceHandle, EfiSimpleFileSystemProtocolGuid, cast[ptr pointer](addr fileSystem)
    )

    quit()

proc EfiMain(imgHandle: EfiHandle, sysTable: ptr EfiSystemTable): EfiStatus {.exportc.} =
    NimMain()

    try:
        return EfiMainInner(imgHandle, sysTable)
    except Exception as e:
        UnhandledException(e)
