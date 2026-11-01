package data_loading

import "core:fmt"
import "core:strings"

Null :: struct {}

DocumentValue :: union {
    string,
    i64,
    f64,
    bool,
    Null,
    []DocumentValue,
    map[string]DocumentValue,
}

documentValue_equals :: proc(a, b: DocumentValue) -> bool {
    switch av in a{
        case string:
            bv, ok := b.(string)
            return ok && av == bv
        case i64:
            bv, ok := b.(i64)
            return ok && av == bv
        case f64:
            bv, ok := b.(f64)
            return ok && av == bv
        case bool:
            bv, ok := b.(bool)
            return ok && av == bv
        case Null:
            _, ok := b.(Null)
            return ok
        case []DocumentValue:
            bv, ok := b.([]DocumentValue)
            if !ok || len(av) != len(bv) {
                return false
            }

            for i in 0..<len(av) {
                if !documentValue_equals(av[i], bv[i]) {
                    return false
                }
            }
            return true
        case map[string]DocumentValue:
            bv, ok := b.(map[string]DocumentValue)
            if !ok || len(av) != len(bv) {
                return false
            }

            for key, value in av {
                other_value, exists := bv[key]
                if !exists || !documentValue_equals(value, other_value) {
                    return false
                }
            }
            return true
    }
    return false
}

@(private)
documentValue_diff :: proc(
    expected, actual: DocumentValue,
    path: string,
    builder: ^strings.Builder,
) {
    switch e in expected {
    case string:
        a, ok := actual.(string)
        if !ok || e != a {
            fmt.sbprintf(builder, "%s:\n  Expected: %v\n  Actual:   %v\n", path, expected, actual)
        }

    case i64:
        a, ok := actual.(i64)
        if !ok || e != a {
            fmt.sbprintf(builder, "%s:\n  Expected: %v\n  Actual:   %v\n", path, expected, actual)
        }

    case f64:
        a, ok := actual.(f64)
        if !ok || e != a {
            fmt.sbprintf(builder, "%s:\n  Expected: %v\n  Actual:   %v\n", path, expected, actual)
        }

    case bool:
        a, ok := actual.(bool)
        if !ok || e != a {
            fmt.sbprintf(builder, "%s:\n  Expected: %v\n  Actual:   %v\n", path, expected, actual)
        }

    case Null:
        _, ok := actual.(Null)
        if !ok {
            fmt.sbprintf(builder, "%s:\n  Expected: %v\n  Actual:   %v\n", path, expected, actual)
        }

    case []DocumentValue:
        a, ok := actual.([]DocumentValue)
        if !ok {
            fmt.sbprintf(builder, "%s:\n  Expected: %v\n  Actual:   %v\n", path, expected, actual)
            return
        }

        if len(e) != len(a) {
            fmt.sbprintf(
                builder,
                "%s: Different sequence lengths (expected %d, actual %d)\n",
                path,
                len(e),
                len(a),
            )
        }

        for i in 0..<min(len(e), len(a)) {
            documentValue_diff(
                e[i],
                a[i],
                fmt.aprintf("%s[%d]", path, i),
                builder,
            )
        }

    case map[string]DocumentValue:
        a, ok := actual.(map[string]DocumentValue)
        if !ok {
            fmt.sbprintf(builder, "%s:\n  Expected: %v\n  Actual:   %v\n", path, expected, actual)
            return
        }

        if len(e) != len(a) {
            fmt.sbprintf(
                builder,
                "%s: Different map sizes (expected %d, actual %d)\n",
                path,
                len(e),
                len(a),
            )
        }

        for key, expected_value in e {
            actual_value, exists := a[key]

            key_path := fmt.aprintf("%s.%s", path, key)

            if !exists {
                fmt.sbprintf(builder, "%s: Missing in actual document\n", key_path)
                continue
            }

            documentValue_diff(
                expected_value,
                actual_value,
                key_path,
                builder,
            )
        }

        for key, actual_value in a {
            _, exists := e[key]
            if !exists {
                fmt.sbprintf(
                    builder,
                    "%s.%s: Unexpected value in actual document: %v\n",
                    path,
                    key,
                    actual_value,
                )
            }
        }
    }
}