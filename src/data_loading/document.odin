package data_loading

import "core:fmt"
import "core:mem"
import "core:strings"

/*
Document represents a document as a recursive tree.

The root is always a string-keyed mapping. Each mapping value may contain any
DocumentValue, including nested mappings and sequences, allowing the complete
document structure to be represented as a tree.
*/
Document :: struct {
    root: map[string]DocumentValue
}

/*
document_equals reports whether two documents contain equivalent values.

Parameters:
    a: The first document to compare.
    b: The second document to compare.

Returns:
    True when both documents contain equal values; otherwise, false.
*/
document_equals :: proc(a, b: Document) -> bool {
    return documentValue_equals(a.root, b.root)
}

/*
get retrieves a top-level value by key.

Parameters:
document: The document to query.
key: The top-level key to look up.

Returns:
The value associated with key and a boolean indicating whether it exists.
*/
get :: proc(
    document: ^Document,
    key: string
) -> (DocumentValue, bool) {
    value, ok := document.root[key]
    return value, ok
}

/*
get_path retrieves a nested value by following a sequence of keys.

Parameters:
document: The document to query.
keys: The keys forming the path to the requested value.

Returns:
The value at the path and a boolean indicating whether the complete path
exists.
*/
get_path :: proc(
    document: ^Document,
    keys: ..string
) -> (DocumentValue, bool) {
    if len(keys) == 0 {
        return {}, false
    }
    
    current := DocumentValue(document.root)
    
    for key in keys {
        object, ok := current.(map[string]DocumentValue)
        if !ok {
            return {}, false
        }
        
        value : DocumentValue
        value, ok = object[key]
        if !ok {
            return {}, false
        }
        
        current = value
    }
    
    return current, true
}

@(private)
document_diff :: proc(
    expected, actual: Document,
    allocator: mem.Allocator,
) -> string {
    builder: strings.Builder
    strings.builder_init(&builder, allocator)
    defer strings.builder_destroy(&builder)

    documentValue_diff(
        expected.root,
        actual.root,
        "root",
        &builder,
    )

    return strings.to_string(builder)
}

debug_print :: proc(document: ^Document) {
    fmt.println("Document {")
    debug_print_mapping(document.root, 1)
    fmt.println("}")
}

debug_print_mapping :: proc(
    mapping: map[string]DocumentValue,
    depth: int,
) {
    for key, value in mapping {
        debug_print_indent(depth)
        fmt.printf("%s: ", key)
        debug_print_value(value, depth)
    }
}

debug_print_value :: proc(
    value: DocumentValue,
    depth: int,
) {
    switch v in value {
    case string:
        fmt.printf("\"%s\"\n", v)
    case i64:
        fmt.printf("%d\n", v)
    case f64:
        fmt.printf("%f\n", v)
    case bool:
        fmt.printf("%v\n", v)
    case Null:
        fmt.println("null")
    case []DocumentValue:
        fmt.println("[")
        for item in v {
            debug_print_indent(depth + 1)
            debug_print_value(item, depth + 1)
        }
        debug_print_indent(depth)
        fmt.println("]")
    case map[string]DocumentValue:
        fmt.println()
        debug_print_mapping(v, depth + 1)
        debug_print_indent(depth)
        fmt.println()
    }
}

debug_print_indent :: proc(depth: int) {
    for _ in 0..<depth {
        fmt.print("    ")
    }
}
