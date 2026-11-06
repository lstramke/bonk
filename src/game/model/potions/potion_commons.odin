package potions

import "../effects"
import "../utils"

Potion_Commons :: struct {
    id: string,
    display_name: string,
    description: string,
    use_time: f32,
    target: Potion_Target,
    effects: []effects.Effect,
    assets: utils.Assets
}
