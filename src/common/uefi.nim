type
    EfiStatus* = uint

    EfiHandle* = pointer

    EfiTableHeader* = object
        signature*: uint64
        revision*: uint32
        headerSize*: uint32
        crc32*: uint32
        reserved*: uint32

    EfiSystemTable* = object
        header*: EfiTableHeader
        firmwareVendor*: WideCString
        firmwareRevision*: uint32
        consoleInHandle*: EfiHandle
        conIn*: pointer
        consoleOutHandle*: EfiHandle
        conOut*: ptr SimpleTextOutputProtocol
        standardErrorHandle*: EfiHandle
        stdErr*: ptr SimpleTextOutputProtocol
        runtimeServices*: pointer
        bootServices*: ptr EfiBootServices
        numTableEntries*: uint
        configTable*: pointer

    SimpleTextOutputProtocol* = object
        reset*: pointer
        outputString*: proc (this: ptr SimpleTextOutputProtocol, str: WideCString): EfiStatus {.cdecl.}
        testString*: pointer
        queryMode*: pointer
        setMode*: pointer
        setAttribute*: proc (this: ptr SimpleTextOutputProtocol, attr: uint64): EfiStatus {.cdecl.}
        clearScreen*: proc (this: ptr SimpleTextOutputProtocol): EfiStatus {.cdecl.}
        setCursorPos*: pointer
        enableCursor*: pointer
        mode*: ptr pointer

    EfiLoadedImageProtocol* = object
        revision*: uint32
        parentHandle*: EfiHandle
        systemTable*: ptr EfiSystemTable
        # Source location of the image
        deviceHandle*: EfiHandle
        filePath*: pointer
        reserved*: pointer
        # Image's load options
        loadOptionsSize*: uint32
        loadOptions*: pointer
        # Location where imge was loaded
        imageBase*: pointer
        imageSize*: uint64
        imageCodeType*: EfiMemoryType
        imageDataType*: EfiMemoryType
        unload*: pointer

    EfiMemoryType* = enum
        EfiReservedMemory
        EfiLoaderCode
        EfiLoaderData
        EfiBootServicesCode
        EfiBootServicesData
        EfiRuntimeServicesCode
        EfiRuntimeServicesData
        EfiConventionalMemory
        EfiUnusableMemory
        EfiACPIReclaimMemory
        EfiACPIMemoryNVS
        EfiMemoryMappedIO
        EfiMemoryMappedIOPortSpace
        EfiPalCode
        EfiPersistentMemory
        EfiUnacceptedMemory
        OsvKernelCode = 0x80000000
        OsvKernelData = 0x80000001
        OsvKernelStack = 0x80000002
        EfiMaxMemoryType

    EfiBootServices* = object
        hdr*: EfiTableHeader
        # task priority services
        raiseTpl*: pointer
        restoreTpl*: pointer
        # memory services
        allocatePages*: pointer
        freePages*: pointer
        getMemoryMap*: pointer
        allocatePool*: pointer
        freePool*: pointer
        # event & timer services
        createEvent*: pointer
        setTimer*: pointer
        waitForEvent*: pointer
        signalEvent*: pointer
        closeEvent*: pointer
        checkEvent*: pointer
        # protocol handler services
        installProtocolInterface*: pointer
        reinstallProtocolInterface*: pointer
        uninstallProtocolInterface*: pointer
        handleProtocol*: proc (handle: EfiHandle, protocol: EfiGuid, `interface`: ptr pointer): EfiStatus {.cdecl.}
        reserved*: pointer
        registerProtocolNotify*: pointer
        locateHandle*: pointer
        locateDevicePath*: pointer
        installConfigurationTable*: pointer

    EfiGuid* = object
        data1: uint32
        data2: uint16
        data3: uint16
        data4: array[8, uint8]

    SimpleTextForegroundColor* = enum
      fgBlack
      fgBlue
      fgGreen
      fgCyan
      fgRed
      fgMagenta
      fgBrown
      fgLightGray
      fgDarkGray
      fgLightBlue
      fgLightGreen
      fgLightCyan
      fgLightRed
      fgLightMagenta
      fgYellow
      fgWhite

    SimpleTextBackgroundColor* = enum
      bgBlack = 0x00
      bgBlue = 0x10
      bgGreen = 0x20
      bgCyan = 0x30
      bgRed = 0x40
      bgMagenta = 0x50
      bgBrown = 0x60
      bgLightGray = 0x70

    EfiSimpleFileSystemProtocol* = object
        revision*: uint64
        openVolume*: pointer

const
    EfiSuccess* = 0
    EfiLoadError* = 1

    EfiLoadedImageProtocolGuid* = EfiGuid(
        data1: 0x5B1B31A1, data2: 0x9562, data3: 0x11d2,
        data4: [0x8e, 0x3f, 0x00, 0xa0, 0xc9, 0x69, 0x72, 0x3b]
    )

    EfiSimpleFileSystemProtocolGuid* = EfiGuid(
        data1: 0x964e5b22'u32, data2: 0x6459, data3: 0x11d2,
        data4: [0x8e, 0x39, 0x00, 0xa0, 0xc9, 0x69, 0x72, 0x3b]
    )

var
    sysTable*: ptr EfiSystemTable

proc W(str: string): WideCString =
    newWideCString(str).toWideCString

proc consoleClear*() =
    assert not sysTable.isNil
    discard sysTable.conOut.clearScreen(sysTable.conOut)

proc consoleOut*(str: string) =
    assert not sysTable.isNil
    discard sysTable.conOut.outputString(sysTable.conOut, W(str))

proc consoleError*(str: string) =
    assert not sysTable.isNil
    discard sysTable.stdErr.outputString(sysTable.stdErr, W(str))

proc consoleOutColor*(
  str: string,
  fg: SimpleTextForegroundColor,
  bg: SimpleTextBackgroundColor = bgBlack
) =
  discard sysTable.conOut.setAttribute(sysTable.conOut, fg.uint + (bg.uint shl 4))
  consoleOut(str)
  discard sysTable.conOut.setAttribute(sysTable.conOut, fgLightGray.uint + (bgBlack.uint shl 4))

proc consoleOutSuccess*(str: string) =
  consoleOutColor(str, fgGreen)

proc consoleOutError*(str: string) =
  consoleOutColor(str, fgLightRed)
