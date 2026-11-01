package data_loading

import "base:runtime"

Data_Loader :: struct {
    reader: Reader,
}

load_data :: proc(
    loader: ^Data_Loader,
    path: string,
    document_allocator: runtime.Allocator
) -> (Document, Load_Error) {
    return loader.reader(path, document_allocator)
}
