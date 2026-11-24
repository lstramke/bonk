
package parsers

import "../../data_loading"

/*
required_string retrieves a value by path and checks whether it is a string.

Parameters:
document: The document to query.
keys: The keys forming the path to the requested value.

Returns:
The string value and a boolean indicating whether the path exists and contains a string.
*/
required_string :: proc(
    document: ^data_loading.Document,
    keys: ..string,
) -> (string, bool) {
    value, exists := data_loading.get_path(document, ..keys)
    if !exists {
        return "", false
    }

    result, ok := value.(string)
    return result, ok
}

/*
required_i64 retrieves a value by path and checks whether it is an i64.

Parameters:
document: The document to query.
keys: The keys forming the path to the requested value.

Returns:
The integer value and a boolean indicating whether the path exists and contains an i64.
*/
required_i64 :: proc(
    document: ^data_loading.Document,
    keys: ..string,
) -> (i64, bool) {
    value, exists := data_loading.get_path(document, ..keys)
    if !exists {
        return 0, false
    }

    result, ok := value.(i64)
    return result, ok
}

/*
required_f64 retrieves a value by path and checks whether it is an f64.

Parameters:
document: The document to query.
keys: The keys forming the path to the requested value.

Returns:
The floating-point value and a boolean indicating whether the path exists and contains an f64.
*/
required_f64 :: proc(
    document: ^data_loading.Document,
    keys: ..string,
) -> (f64, bool) {
    value, exists := data_loading.get_path(document, ..keys)
    if !exists {
        return 0, false
    }

    result, ok := value.(f64)
    return result, ok
}

/*
required_bool retrieves a value by path and checks whether it is a boolean.

Parameters:
document: The document to query.
keys: The keys forming the path to the requested value.

Returns:
The boolean value and a boolean indicating whether the path exists and contains a bool.
*/
required_bool :: proc(
    document: ^data_loading.Document,
    keys: ..string,
) -> (bool, bool) {
    value, exists := data_loading.get_path(document, ..keys)
    if !exists {
        return false, false
    }

    result, ok := value.(bool)
    return result, ok
}

/*
required_array retrieves a value by path and checks whether it is an array.

Parameters:
document: The document to query.
keys: The keys forming the path to the requested value.

Returns:
The array value and a boolean indicating whether the path exists and contains an array.
*/
required_array :: proc(
    document: ^data_loading.Document,
    keys: ..string,
) -> ([]data_loading.DocumentValue, bool) {
    value, exists := data_loading.get_path(document, ..keys)
    if !exists {
        return nil, false
    }

    result, ok := value.([]data_loading.DocumentValue)
    return result, ok
}

/*
required_mapping retrieves a value by path and checks whether it is a mapping.

Parameters:
document: The document to query.
keys: The keys forming the path to the requested value.

Returns:
The mapping value and a boolean indicating whether the path exists and contains a mapping.
*/
required_mapping :: proc(
    document: ^data_loading.Document,
    keys: ..string,
) -> (map[string]data_loading.DocumentValue, bool) {
    value, exists := data_loading.get_path(document, ..keys)
    if !exists {
        return nil, false
    }

    result, ok := value.(map[string]data_loading.DocumentValue)
    return result, ok
}
