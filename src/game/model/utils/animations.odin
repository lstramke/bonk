package utils

Animation :: struct {
    frames: []int,
    fps: f32,
}

animation_equals :: proc(a, b: Animation) -> bool {
    if a.fps != b.fps || len(a.frames) != len(b.frames) {
        return false
    }

    for i in 0..<len(a.frames) {
        if a.frames[i] != b.frames[i] {
            return false
        }
    }

    return true
}