import debugcon, common/libc, common/malloc

proc KernelMain() {.exportc.} =
    debugln "Hello, world!"
    quit()
