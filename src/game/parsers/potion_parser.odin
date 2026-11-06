package parsers

import "base:runtime"
import "../../data_loading"
import "../model/potions"

parse_potion :: proc(
    document: ^data_loading.Document,
    allocator: runtime.Allocator,
) -> (potions.Potion, Parse_Error) {
    if len(document.root) == 0 {
        return {}, Parse_Error{
            type = .EMPTY_DOCUMENT,
            message = "potion document is empty",
        }
    }

    

    return {}, {}
}
