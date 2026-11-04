package data_loading

Load_Error :: struct {
    type: Load_Error_Type,
    message: string
}

Load_Error_Type :: enum {
    NONE,
    ASSET_ROOT_NOT_FOUND,
    EXECUTABLE_DIR_NOT_FOUND,
    PATH_RESOLUTION_FAILED,
    INVALID_FILE_PATH,
    FILE_NOT_FOUND,
    FILE_READ_FAILED,
    INVALID_FORMAT,
    EMPTY_FILE
}