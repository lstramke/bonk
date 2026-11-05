package weapons

import "../utils"

Melee_Weapon :: struct {
    using common: Weapon_Common,

    range: f32,
    hitbox: utils.Hitbox,
}