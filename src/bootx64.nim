import malloc
import libc

type
    EfiStatus = uint

    EfiHandle = pointer

    EfiTableHeader = object
        signature: uint64
        revision: uint32
        headerSize: uint32
        crc32: uint32
        reserved: uint32

    EfiSystemTable = object
        header: EfiTableHeader
        firmwareVendor: WideCString
        firmwareRevision: uint32
        consoleInHandle: EfiHandle
        conIn: pointer
        consoleOutHandle: EfiHandle
        conOut: ptr SimpleTextOutputProtocol
        standardErrorHandle: EfiHandle
        stdErr: SimpleTextOutputProtocol
        runtimeServices: pointer
        bootServices: pointer
        numTableEntries: uint
        configTable: pointer

    SimpleTextOutputProtocol = object
        reset: pointer
        outputString: proc (this: ptr SimpleTextOutputProtocol, str: WideCString): EfiStatus {.cdecl.}
        testString: pointer
        queryMode: pointer
        setMode: pointer
        setAttribute: pointer
        clearScreen: proc (this: ptr SimpleTextOutputProtocol): EfiStatus {.cdecl.}
        setCursorPos: pointer
        enableCursor: pointer
        mode: ptr pointer

const
    EfiSuccess = 0
    EfiLoadError = 1

proc NimMain() {.importc.}

proc EfiMain(imgHandle: EfiHandle, sysTable: ptr EfiSystemTable): EfiStatus {.exportc.} =
    NimMain()
    return EfiLoadError
