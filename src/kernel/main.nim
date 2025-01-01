import common/malloc
import common/libc

proc NimMain() {.importc.}

proc main(): int {.exportc.} =
    NimMain()
    return 0
