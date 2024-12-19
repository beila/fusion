import malloc
import libc

proc NimMain() {.importc.}

proc main(): int {.exportc.} =
    NimMain()
    return 0
