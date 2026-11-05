package weapons

import "../utils"

Ranged_Weapon :: struct {
    using common: Weapon_Common,

    range: f32,
    projectile: utils.Projectile,
}