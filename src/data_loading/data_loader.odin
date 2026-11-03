package data_loading

import "base:runtime"

/*
Data_Loader provides a common interface for loading documents through a
configured Reader.
*/
Data_Loader :: struct {
    reader: Reader,
}

/*
create_yaml_data_loader returns a Data_Loader configured to read YAML
documents.

Returns:
    A Data_Loader configured with yaml_reader.
*/
create_yaml_data_loader :: proc() -> Data_Loader {
    return Data_Loader{
        reader= yaml_reader
    }
}

/*
load_data loads the document at path using loader and allocates its contents
with document_allocator.

Parameters:
    loader: The data loader used to read the document as pointer.
    path: The path of the document to load.
    document_allocator: The allocator used for document contents.

Returns:
    The loaded Document and a Load_Error. The error type is NONE on success.
*/
load :: proc(
    loader: ^Data_Loader,
    path: string,
    document_allocator: runtime.Allocator
) -> (Document, Load_Error) {
    return loader.reader(path, document_allocator)
}
