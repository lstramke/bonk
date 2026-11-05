package weapons

import "../utils"

Weapon_Common :: struct {
    id: string,
    display_name: string,
    description: string,
    damage: map[utils.Damage_Type]f32,
    attack: Attack,
    assets: utils.Assets
}