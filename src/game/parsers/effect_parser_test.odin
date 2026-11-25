#+feature dynamic-literals

package parsers

import "core:testing"
import "core:log"
import "../../data_loading"
import "../model/effects"
import "../model/utils"

Effect_Testcase :: struct {
    description: string,
    document: ^data_loading.Document,
    expected: effects.Effect,
    expected_error: Parse_Error_Type,
}

@(private="file")
make_effect_document :: proc(
    id: string,
    effect_type: string,
    defaults: map[string]data_loading.DocumentValue,
) -> ^data_loading.Document {
    document := new(data_loading.Document, context.allocator)
    document^ = data_loading.Document{
        root = {
            "id" = id,
            "type" = effect_type,
            "defaults" = defaults,
            "assets" = {
                "status_sprite" = "sprites/test.png",
            },
        },
    }
    return document
}

@(test)
test_effect_parser :: proc(t: ^testing.T) {
    defer free_all(context.allocator)

    test_assets := utils.Assets{
        visual = utils.Sprite{path = "sprites/test.png"},
    }

    effect_testcases := []Effect_Testcase{
        {
            description = "instant heal",
            document = make_effect_document("test_heal", "heal", {
                "amount" = i64(50),
            }),
            expected = effects.Instant_Heal{
                id = "test_heal",
                assets = test_assets,
                amount = 50,
            },
            expected_error = .NONE,
        },
        {
            description = "heal over time",
            document = make_effect_document("test_hot", "heal", {
                "amount_per_tick" = i64(10),
                "duration" = i64(5),
            }),
            expected = effects.Heal_Over_Time{
                id = "test_hot",
                assets = test_assets,
                amount_per_tick = 10,
                duration = 5,
            },
            expected_error = .NONE,
        },
        {
            description = "speed modifier",
            document = make_effect_document("test_speed", "speed_modifier", {
                "multiplier" = f64(1.5),
                "duration" = f64(10.0),
            }),
            expected = effects.Speed_Modifier{
                id = "test_speed",
                assets = test_assets,
                multiplier = 1.5,
                duration = 10.0,
            },
            expected_error = .NONE,
        },
        {
            description = "unsupported effect type",
            document = make_effect_document("test_unknown", "unknown", {}),
            expected_error = .INVALID_FORMAT,
        },
        {
            description = "heal without defaults",
            document = make_effect_document("test_invalid_heal", "heal", {}),
            expected_error = .INVALID_FORMAT,
        },
        {
            description = "heal with both amount fields",
            document = make_effect_document("test_invalid_heal", "heal", {
                "amount" = i64(50),
                "amount_per_tick" = i64(10),
            }),
            expected_error = .INVALID_FORMAT,
        },
    }

    for test_case in effect_testcases {
        effect, parse_error := parse_effect(
            test_case.document,
            context.allocator,
        )

        if !testing.expect_value(t, parse_error.type, test_case.expected_error) {
            log.errorf(
                "%s: unexpected error: %s",
                test_case.description,
                parse_error.message,
            )
            continue
        }

        if test_case.expected_error == .NONE {
            testing.expect(
                t,
                effects.effect_equals(effect, test_case.expected),
                test_case.description,
            )
        }
    }
}
