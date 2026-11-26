package utils

Audio :: struct {
    clips: map[string]string,
}

audio_equals :: proc(a, b: Audio) -> bool {
    if len(a.clips) != len(b.clips) {
        return false
    }

    for key, value in a.clips {
        other, ok := b.clips[key]
        if !ok || value != other {
            return false
        }
    }

    return true
}
