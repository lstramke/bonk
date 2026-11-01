package data_loading

import "core:strconv"
import "core:strings"
import "base:runtime"
import "core:os"
import "core:fmt"

yaml_reader :: proc(
    path: string, 
    document_allocator: runtime.Allocator
) -> (Document, Load_Error) {
    defer free_all(context.temp_allocator)
    
    source_bytes, oserr := os.read_entire_file_from_path(path, context.temp_allocator)
    if oserr != nil {
        switch oserr {
            case .Not_Exist:
                return {}, Load_Error{.FILE_NOT_FOUND, "No file for given path"}
            case:
                return {}, Load_Error{.FILE_READ_FAILED, "Could not read file"}
        }
    }

    source := string(source_bytes)
    lines := tokenize_yaml(source, context.temp_allocator)
    when ODIN_DEBUG {
        for line in lines {
            fmt.printf("Zeile %d: indent=%d, content='%s'\n",
                line.line_number,
                line.indent,
                line.content,
            )
        }
    }

    document, err := parse_yaml(lines, document_allocator)
    if err.type != .NONE {
        return {}, err
    }

    return document, {}
}

@(private="file")
Yaml_Line :: struct{
    indent: int,
    content: string,
    line_number: int
}

@(private="file")
tokenize_yaml :: proc(
    source: string, 
    allocator: runtime.Allocator
) -> []Yaml_Line {
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
                line_number = line_number,
            })
        }

        line_start = i + 1
        line_number += 1
    }
    return lines[:]
}

@(private="file")
parse_yaml :: proc(
    lines: []Yaml_Line,
    document_allocator: runtime.Allocator
) -> (Document, Load_Error) {
    if len(lines) == 0 {
        return {}, {.EMPTY_FILE, "file must be not empty"}
    }

    index := 0
    root, err := parse_collection(lines, &index, lines[0].indent, document_allocator)
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

@(private="file")
parse_collection :: proc(
    lines: []Yaml_Line,
    index: ^int,
    indent: int,
    document_allocator: runtime.Allocator,
) -> (DocumentValue, Load_Error) {
    if index^ >= len(lines) {
        return {}, {}
    }

    line := lines[index^]
    if line.indent != indent {
        return {}, {}
    }

    if strings.has_prefix(line.content, "- ") {
        sequence, err := parse_sequence(lines, index, indent, document_allocator)
        if err.type != .NONE {
            return {}, err
        }

        return DocumentValue(sequence), {}
    }

    mapping, err := parse_mapping(lines, index, indent, document_allocator)
    if err.type != .NONE {
        return {}, err
    }

    return DocumentValue(mapping), {}
}

@(private="file")
parse_mapping :: proc(
    lines: []Yaml_Line,
    index: ^int,
    indent: int,
    document_allocator: runtime.Allocator,
) -> (map[string]DocumentValue, Load_Error) {
    mapping := make(map[string]DocumentValue, document_allocator)

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

        key := strings.clone(line.content[:separator_index], document_allocator)
        value := strings.trim_space(line.content[separator_index + 1:])
        
        if len(value) > 0 {
            scalarValue, err := parse_scalarValue(value, document_allocator)
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
                document_allocator,
            )
        
            if err.type != .NONE {
                return {}, err
            }
        
            mapping[key] = node
        }
    }

    return mapping, {}
}

@(private="file")
parse_sequence :: proc(
    lines: []Yaml_Line,
    index: ^int,
    indent: int,
    document_allocator: runtime.Allocator,
) -> ([]DocumentValue, Load_Error) {
    sequence := make([dynamic]DocumentValue, document_allocator)

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

                mapping, err := parse_mapping(lines, index, indent + 2, document_allocator)
                if err.type != .NONE {
                    return {}, err
                }
                append(&sequence, mapping)
            } else {
                scalarValue, err := parse_scalarValue(line_value, document_allocator)
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
                document_allocator,
            )
        
            if err.type != .NONE {
                return {}, err
            }
        
            append(&sequence, node)
        }
    }

    return sequence[:], {}
}

@(private="file")
parse_scalarValue :: proc(
    value: string,
    document_allocator: runtime.Allocator,
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
        return parse_inline_array(value[1:len(value)-1], document_allocator)
    }

    integer, i_ok := strconv.parse_i64(value)
    if i_ok {
        return integer, {}
    }

    float, f_ok := strconv.parse_f64(value)
    if f_ok {
        return float, {}
    }

    if len(value) >= 2 && value[0] == '{' && value[len(value)-1] == '}' {
        return {}, {.INVALID_FORMAT, "Flow mappings are not supported"}
    }

    return DocumentValue(strings.clone(value, document_allocator)), {}
}

@(private="file")
parse_inline_array :: proc(
    value: string, 
    document_allocator: runtime.Allocator
) -> ([]DocumentValue, Load_Error) {
    inline_array := make([dynamic]DocumentValue, document_allocator)

    array_elements := strings.split(value, ",", context.temp_allocator)

    for array_element in array_elements {
        element := strings.trim_space(array_element)

        parsed_element, err := parse_scalarValue(element, document_allocator)
        if err.type != .NONE{
            return {}, err
        }
        append(&inline_array, parsed_element)
    }

    return inline_array[:], {}
}
