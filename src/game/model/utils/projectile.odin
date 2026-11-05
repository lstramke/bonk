package utils

Projectile :: struct {
    speed: f32,
    lifetime: f32,
    trajectory: Trajectory,
    hitbox: Hitbox,
}

Trajectory :: enum {
    STRAIGHT,
    BALLISTIC,
}