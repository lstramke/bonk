package effects

import "../utils"

Effect :: union #no_nil{
    Instant_Heal,
    Heal_Over_Time,
    Speed_Modifier,
}

get_effect_id :: proc(effect: ^Effect) -> string {
    switch value in effect {
    case Instant_Heal:
        return value.id
    case Heal_Over_Time:
        return value.id
    case Speed_Modifier:
        return value.id
    }
    
    return ""
}

effect_equals :: proc(a, b: Effect) -> bool {
    switch av in a {
    case Instant_Heal:
        bv, ok := b.(Instant_Heal)
        return ok &&
            av.id == bv.id &&
            utils.assets_equals(av.assets, bv.assets) &&
            av.amount == bv.amount

    case Heal_Over_Time:
        bv, ok := b.(Heal_Over_Time)
        return ok &&
            av.id == bv.id &&
            utils.assets_equals(av.assets, bv.assets) &&
            av.amount_per_tick == bv.amount_per_tick &&
            av.duration == bv.duration

    case Speed_Modifier:
        bv, ok := b.(Speed_Modifier)
        return ok &&
            av.id == bv.id &&
            utils.assets_equals(av.assets, bv.assets) &&
            av.multiplier == bv.multiplier &&
            av.duration == bv.duration
    }

    return false
}
