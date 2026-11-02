package data_loading

import "base:runtime"

/*
Reader defines the procedure signature required to load a document.

Any reader implementation must accept a file path and a runtime allocator,
and must return a Document together with a Load_Error.
The path must already be resolved by the configured path resolver. A Reader
must not resolve environment-specific paths or validate the logical path.
All memory owned by the returned Document must be allocated through the given
document_allocator.

Parameters:
    path: The resolved file path of the document to load.
    document_allocator: The allocator used for document contents.

Returns:
    The loaded Document and a Load_Error describing whether loading succeeded.
*/
Reader :: proc(
    path: string, 
    document_allocator: runtime.Allocator
) -> (Document, Load_Error)
