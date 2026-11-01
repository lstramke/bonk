package data_loading

Null :: struct {}

DocumentValue :: union {
    string,
    i64,
    f64,
    bool,
    Null,
    [dynamic]DocumentValue,
    map[string]DocumentValue,
}

documentValue_equals :: proc(a,b: DocumentValue) -> bool {
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
        case [dynamic]DocumentValue:
            bv, ok := b.([dynamic]DocumentValue)
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
