package data_loading

Load_Error :: struct {
    type: Load_Error_Type,
    message: string
}

Load_Error_Type :: enum {
    NONE,
    FILE_NOT_FOUND,
    FILE_READ_FAILED,
    INVALID_FORMAT,
    EMPTY_FILE
}