package effects

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