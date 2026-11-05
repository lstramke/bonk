package utils

Hitbox :: union {
    Circle_Hitbox,
    Arc_Hitbox
}

Circle_Hitbox :: struct {
    radius: f32,
}

Arc_Hitbox :: struct {
    width: f32,
    height: f32,
    offset: [2]f32,
}
