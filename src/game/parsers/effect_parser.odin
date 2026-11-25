package parsers

import "base:runtime"
import "core:strings"
import "core:log"
import "../../data_loading"
import "../model/effects"
import "../model/utils"

parse_effect :: proc(
    document: ^data_loading.Document,
    allocator: runtime.Allocator
) -> (effects.Effect, Parse_Error) {
    if len(document.root) == 0 {
        return {}, Parse_Error{
            type = .EMPTY_DOCUMENT,
            message = "effect document is empty",
        }
    }

    id, id_is_ok := required_string(document, "id")
    if !id_is_ok {
        return {}, invalid_effect("field 'id' is missing or must be a string")
    }

    effect_type, effect_type_is_ok := required_string(document, "type")
    if !effect_type_is_ok {
        return {}, invalid_effect("field 'type' is missing or must be a string")
    }

    assets, assets_err := parse_effect_assets(document, allocator)
    if assets_err.type != .NONE {
        return {}, assets_err
    }
    commons := effects.Effect_Commons{
        id = strings.clone(id, allocator),
        assets = assets,
    }

    effect : effects.Effect
    parse_err : Parse_Error

    switch effect_type {
        case "heal":
            effect, parse_err =  parse_heal(document, commons)
        case "speed_modifier":
            effect, parse_err = parse_speed_modifier(document, commons)
        case:
            return {}, invalid_effect(strings.concatenate({"unsupported effect type: ", effect_type}, allocator))
    }

    if parse_err.type != .NONE {
        return {}, parse_err
    }

    log.debugf("Parsed effect '%s' (type: %s)", id, effect_type)
    return effect, {}
}

@(private="file")
invalid_effect :: proc(message: string) -> Parse_Error {
    return Parse_Error{type = .INVALID_FORMAT, message = message}
}

@(private="file")
parse_effect_assets :: proc(
    document: ^data_loading.Document,
    allocator: runtime.Allocator,
) -> (utils.Assets, Parse_Error) {
    base_mapping :: "assets"

    sprite, sprite_is_ok := required_string(document, base_mapping, "status_sprite")
    if !sprite_is_ok {
        return {}, invalid_effect("asset 'status_sprite' is missing or must be a string")
    }

    clips := make(map[string]string, allocator)
    audio_value, has_audio := data_loading.get_path(document, base_mapping, "audio")
    if has_audio {
        if audio_mapping, is_mapping := audio_value.(map[string]data_loading.DocumentValue); is_mapping {
            for name, clip_value in audio_mapping {
                if _, is_null := clip_value.(data_loading.Null); is_null {
                    continue
                }

                clip, is_string := clip_value.(string)
                if !is_string {
                    return {}, invalid_effect("audio clip paths must be strings or null")
                }

                clips[strings.clone(name, allocator)] = strings.clone(clip, allocator)
            }
        } else {
            _, is_null := audio_value.(data_loading.Null)
            if !is_null {
                return {}, invalid_effect("asset 'audio' must be a mapping or null")
            }
        }
    }

    return utils.Assets{
        visual = utils.Sprite{
            path = strings.clone(sprite, allocator),
        },
        audio = utils.Audio{clips = clips},
    }, {}
}

@(private="file")
parse_heal :: proc(
    document: ^data_loading.Document,
    commons: effects.Effect_Commons,
) -> (effects.Effect, Parse_Error) {
    base_mapping :: "defaults"
    amount, has_amount := required_i64(document, base_mapping, "amount")
    amount_per_tick, has_amount_per_tick := required_i64(document, base_mapping, "amount_per_tick")

    if has_amount == has_amount_per_tick {
        return {}, invalid_effect(
            "heal defaults must contain exactly one of 'amount' or 'amount_per_tick'",
        )
    }

    if has_amount {
        return effects.Instant_Heal{
            commons = commons,
            amount = i32(amount),
        }, {}
    }

    duration, duration_is_ok := required_i64(document, base_mapping, "duration")
    if !duration_is_ok {
        return {}, invalid_effect(
            "heal-over-time 'duration' is missing or must be an integer",
        )
    }

    return effects.Heal_Over_Time{
        commons = commons,
        amount_per_tick = i32(amount_per_tick),
        duration = f32(duration),
    }, {}
}

@(private="file")
parse_speed_modifier :: proc(
    document: ^data_loading.Document,
    commons: effects.Effect_Commons,
) -> (effects.Effect, Parse_Error) {
    base_mapping :: "defaults"
    multiplier, multiplier_is_ok := required_f64(document, base_mapping, "multiplier")
    if !multiplier_is_ok {
        return {}, invalid_effect("speed modifier 'multiplier' is missing or must be a number")
    }

    duration, duration_is_ok := required_f64(document, base_mapping, "duration")
    if !duration_is_ok {
        return {}, invalid_effect("speed modifier 'duration' is missing or must be a number")
    }

    return effects.Speed_Modifier{
        commons = commons,
        multiplier = f32(multiplier),
        duration = f32(duration),
    }, {}
}
