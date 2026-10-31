package data_loading

import "core:strconv"
import "core:strings"
import "base:runtime"
import "core:os"
import "core:fmt"

yaml_reader :: proc(
    path: string, 
    allocator: runtime.Allocator
) -> (Document, Load_Error) {
    source_bytes, oserr := os.read_entire_file_from_path(path, allocator)

    if oserr != nil {
        switch oserr {
            case .Not_Exist:
                return {}, Load_Error{.FILE_NOT_FOUND, "No file for given path"}
            case:
                return {}, Load_Error{.FILE_READ_FAILED, "Could not read file"}
        }
    }

    source := string(source_bytes)
    lines := tokenize_yaml(source, allocator)
    for line in lines {
        fmt.printf("Zeile %d: indent=%d, content='%s'\n",
            line.line_number,
            line.indent,
            line.content,
        )
    }

    document, err := parse_yaml(lines[:], allocator)
    if err.type != .NONE {
        return {}, err
    }

    return document, {}
}

@(private)
Yaml_Line :: struct{
    indent: int,
    content: string,
    line_number: int
}

@(private)
tokenize_yaml :: proc(
    source: string, 
    allocator: runtime.Allocator
) -> [dynamic]Yaml_Line {
    lines := make([dynamic]Yaml_Line, allocator)

    line_start := 0
    line_number := 1
    len_source := len(source)

    for i:= 0; i<= len_source; i+=1 {
        if i < len_source && source[i] != '\n' {
            continue
        }

        line_end := i

        if line_end > line_start && source[line_end - 1] == '\r' {
            line_end -= 1
        }

        raw_line := source[line_start:line_end]

        indent := 0
        for indent < len(raw_line) && raw_line[indent] == ' ' {
            indent += 1
        }

        content := raw_line[indent:]

        if len(content) > 0 && content[0] != '#' {
            append(&lines, Yaml_Line {
                indent  = indent,
                content = content,
                line_number    = line_number,
            })
        }

        line_start = i + 1
        line_number += 1
    }
    return lines
}

@(private)
parse_yaml :: proc(
    lines: []Yaml_Line,
    allocator: runtime.Allocator
) -> (Document, Load_Error) {
    if len(lines) == 0 {
        return {}, {.EMPTY_FILE, "file must be not empty"}
    }

    index := 0
    root, err := parse_collection(lines, &index, lines[0].indent, allocator)
    if err.type != .NONE {
        return {}, err
    }
    if index != len(lines) {
        return {}, {.INVALID_FORMAT, "Not all lines were parsed"}
    }

    root_object, ok := root.(map[string]DocumentValue)
    if !ok {
        return {}, {.FILE_READ_FAILED, "file root object must be a map of string to DocumentValue"}
    }

    return Document{root = root_object}, {}
}

@(private)
parse_collection :: proc(
    lines: []Yaml_Line,
    index: ^int,
    indent: int,
    allocator: runtime.Allocator,
) -> (DocumentValue, Load_Error) {
    if index^ >= len(lines) {
        return {}, {}
    }

    line := lines[index^]
    if line.indent != indent {
        return {}, {}
    }

    if strings.has_prefix(line.content, "- ") {
        sequence, err := parse_sequence(lines, index, indent, allocator)
        if err.type != .NONE {
            return {}, err
        }

        return DocumentValue(sequence), {}
    }

    mapping, err := parse_mapping(lines, index, indent, allocator)
    if err.type != .NONE {
        return {}, err
    }

    return DocumentValue(mapping), {}
}

@(private)
parse_mapping :: proc(
    lines: []Yaml_Line,
    index: ^int,
    indent: int,
    allocator: runtime.Allocator,
) -> (map[string]DocumentValue, Load_Error) {
    mapping := make(map[string]DocumentValue, allocator)

    for index^ < len(lines) {
        line := lines[index^]

        if line.indent < indent {
            break
        }

        if line.indent > indent {
            return {}, {.INVALID_FORMAT, "Unexpected indentation"}
        }

        separator_index := strings.index(line.content, ":")
        if separator_index < 0 {
            return {}, {.INVALID_FORMAT, "Expected ':' in mapping entry"}
        }

        key := line.content[:separator_index]
        value := strings.trim_space(line.content[separator_index + 1:])
        
        if len(value) > 0 {
            scalarValue, err := parse_scalarValue(value, allocator)
            if err.type != .NONE {
                return {}, err
            }

            mapping[key] = scalarValue
            index^ += 1
        } else {
            index^ += 1

            if index^ >= len(lines) || lines[index^].indent <= indent {
                return {}, {.INVALID_FORMAT, "Expected nested collection"}
            }

            node, err := parse_collection(
                lines,
                index,
                lines[index^].indent,
                allocator,
            )
        
            if err.type != .NONE {
                return {}, err
            }
        
            mapping[key] = node
        }
    }

    return mapping, {}
}

@(private)
parse_sequence :: proc(
    lines: []Yaml_Line,
    index: ^int,
    indent: int,
    allocator: runtime.Allocator,
) -> ([dynamic]DocumentValue, Load_Error) {
    sequence := make([dynamic]DocumentValue, allocator)

    for index^ < len(lines) {
        line := lines[index^]

        if line.indent < indent {
            break
        }

        if line.indent > indent {
            return {}, {.INVALID_FORMAT, "Unexpected indentation"}
        }

        line_value := strings.trim_space(line.content[2:])

        if len(line_value) > 0 {
            if strings.index(line_value, ":") >= 0 {
                lines[index^].content = strings.trim_space(line.content[2:])
                lines[index^].indent += 2

                mapping, err := parse_mapping(lines, index, indent + 2, allocator)
                if err.type != .NONE {
                    return {}, err
                }
                append(&sequence, mapping)
            } else {
                scalarValue, err := parse_scalarValue(line_value, allocator)
                if err.type != .NONE {
                    return {}, err
                }

                append(&sequence, scalarValue)
                index^ += 1
            }
        } else {
           index^ += 1

            if index^ >= len(lines) || lines[index^].indent <= indent {
                return {}, {.INVALID_FORMAT, "Expected nested collection"}
            }

            node, err := parse_collection(
                lines,
                index,
                lines[index^].indent,
                allocator,
            )
        
            if err.type != .NONE {
                return {}, err
            }
        
            append(&sequence, node)
        }
    }

    return sequence, {}
}

@(private)
parse_scalarValue :: proc(
    value: string,
    allocator: runtime.Allocator,
) -> (DocumentValue, Load_Error) {

    if value == "null" || value == "[]" {
        return Null{}, {}
    }

    if value == "true" {
        return true, {}
    }

    if value == "false" {
        return false, {}
    }

    if len(value) > 2 && value[0] == '[' && value[len(value)-1] == ']' {
        return parse_inline_array(value[1:len(value)-1], allocator)
    }

    integer, i_ok := strconv.parse_i64(value)
    if i_ok {
        return integer, {}
    }

    float, f_ok := strconv.parse_f64(value)
    if f_ok {
        return float, {}
    }

    return DocumentValue(value), {}
}

@(private)
parse_inline_array :: proc(
    value: string, 
    allocator: runtime.Allocator
) -> ([dynamic]DocumentValue, Load_Error) {
    inline_array := make([dynamic]DocumentValue, allocator)

    array_elements := strings.split(value, ",")

    for array_element in array_elements {
        element := strings.trim_space(array_element)

        parsed_element, err := parse_scalarValue(element, allocator)
        if err.type != .NONE {
            return {}, err
        }

        append(&inline_array, parsed_element)
    }

    return inline_array, {}
}
