package parsers

Parse_Error :: struct {
    type: Parse_Error_Type,
    message: string,
}

Parse_Error_Type :: enum {
    NONE,
    EMPTY_DOCUMENT,
    INVALID_FORMAT,
}
