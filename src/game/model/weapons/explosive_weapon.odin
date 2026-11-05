package weapons

import "../utils"

Explosive_Weapon :: struct {
    using common: Weapon_Common,

    range: f32,
    delivery: utils.Projectile,
    explosion: utils.Explosion,
}