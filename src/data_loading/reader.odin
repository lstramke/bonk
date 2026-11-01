package data_loading

import "base:runtime"

Reader :: proc(
    path: string, 
    document_allocator: runtime.Allocator
) -> (Document, Load_Error)
