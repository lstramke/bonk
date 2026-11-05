package utils

Explosion :: struct {
    trigger: Explosion_Trigger,
    timer: f32,
    mode: Explosion_Mode,
    hitbox: Hitbox,
    effect: Explosion_Effect,
    affects_owner: bool,
}

Explosion_Trigger :: enum {
    TIMER,
}

Explosion_Mode :: enum {
    INSTANT,
}

Explosion_Effect :: enum {
    DAMAGE,
}