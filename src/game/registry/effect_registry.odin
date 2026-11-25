package registry

import "base:runtime"
import "../model/effects"

Effect_Registry :: struct {
    definitions: map[string]effects.Effect,
}

create_effect_registry :: proc(allocator: runtime.Allocator) -> Effect_Registry {
    return Effect_Registry{
        definitions = make(map[string]effects.Effect, allocator),
    }
}

register_effect :: proc(
    registry: ^Effect_Registry,
    effect: ^effects.Effect,
) {
    registry.definitions[effects.get_effect_id(effect)] = effect^
}

get_effect :: proc(
    registry: ^Effect_Registry,
    id: string,
) -> (effects.Effect, bool) {
    effect, exists := registry.definitions[id]
    return effect, exists
}
