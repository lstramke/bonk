package utils

Assets :: struct {
    visual: Visual,
    audio: Audio,
}

assets_equals :: proc(a, b: Assets) -> bool {
    return visual_equals(a.visual, b.visual) &&
        audio_equals(a.audio, b.audio)
}