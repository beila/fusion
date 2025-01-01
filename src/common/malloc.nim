{.used.}

var
    heap*: array[1*1024*1024, byte]
    heapBumpPtr*: int = cast[int](addr heap)
    heapMaxPtr*: int = cast[int](addr heap) + heap.high

proc free*(p: pointer) {.exportc.} =
    discard

proc malloc*(size: csize_t): pointer {.exportc.} =
    if heapBumpPtr + size.int > heapMaxPtr:
        return nil

    result = cast[pointer](heapBumpPtr)
    inc heapBumpPtr, size.int

proc calloc*(num: csize_t, size: csize_t): pointer {.exportc.} =
    result = malloc(size * num)

proc realloc*(p: pointer, new_size: csize_t): pointer {.exportc.} =
    result = malloc(new_size)
    copyMem(result, p, new_size)
    free(p)
