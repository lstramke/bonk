package utils

Visual :: union {
    Sprite,
    Spritesheet,
}

Sprite :: struct {
    path: string,
}

Spritesheet :: struct {
    path: string,
    animations: map[string]Animation,
}

visual_equals :: proc(a, b: Visual) -> bool {
    switch av in a {
    case Sprite:
        bv, ok := b.(Sprite)
        return ok && av.path == bv.path

    case Spritesheet:
        bv, ok := b.(Spritesheet)
        if !ok || av.path != bv.path || len(av.animations) != len(bv.animations) {
            return false
        }

        for key, animation in av.animations {
            other, ok := bv.animations[key]
            if !ok || !animation_equals(animation, other) {
                return false
            }
        }

        return true
    }

    return false
}
