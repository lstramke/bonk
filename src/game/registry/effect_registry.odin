package registry

import "base:runtime"
import "core:log"
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
) -> bool {
    id := effects.get_effect_id(effect)

    if _, exists := registry.definitions[id]; exists {
        log.warnf("Effect '%s' is already registered", id)
        return false
    }

    registry.definitions[id] = effect^

    log.infof("Registered effect '%s'", id)
    return true
}

get_effect :: proc(
    registry: ^Effect_Registry,
    id: string,
) -> (effects.Effect, bool) {
    effect, exists := registry.definitions[id]
    return effect, exists
}
