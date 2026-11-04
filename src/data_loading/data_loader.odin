package data_loading

import "base:runtime"

/*
Data_Loader provides a common interface for loading documents through a
configured Reader.
*/
Data_Loader :: struct {
    reader: Reader,
    path_resolver: Path_Resolver
}

/*
create_yaml_data_loader returns a Data_Loader configured to read YAML
documents through path_resolver.

Parameters:
    path_resolver: The resolver used to convert asset-relative paths before
        they are passed to yaml_reader.

Returns:
    A Data_Loader configured with yaml_reader and path_resolver.
*/
create_yaml_data_loader :: proc(
    path_resolver: Path_Resolver,
) -> Data_Loader {
    return Data_Loader{
        reader = yaml_reader,
        path_resolver = path_resolver,
    }
}

/*
load loads the document at the asset-relative path using loader and allocates
its contents
with document_allocator.

Parameters:
    loader: The data loader used to read the document as pointer.
    path: The asset-relative path of the document to load.
    document_allocator: The allocator used for document contents.

Returns:
    The loaded Document and a Load_Error. The error type is NONE on success.
*/
load :: proc(
    loader: ^Data_Loader,
    path: string,
    document_allocator: runtime.Allocator
) -> (Document, Load_Error) {
    resolved_path, resolve_err := resolve_asset_path(&loader.path_resolver, path)
    if resolve_err.type != .NONE {
        return {}, resolve_err
    }
    defer delete(resolved_path)

    return loader.reader(resolved_path, document_allocator)
}
