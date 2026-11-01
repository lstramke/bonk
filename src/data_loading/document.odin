package data_loading

import "core:fmt"
import "core:mem"
import "core:strings"

Document :: struct {
    root: map[string]DocumentValue
}

document_equals :: proc(a, b: Document) -> bool {
    return documentValue_equals(a.root, b.root)
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

get :: proc(
    document: ^Document,
    key: string
) -> (DocumentValue, bool) {
    value, ok := document.root[key]
    return value, ok
}

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
