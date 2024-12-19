proc W*(str: string): WideCString =
    newWideCString(str).toWideCString

