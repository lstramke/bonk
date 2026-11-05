package weapons

Attack :: struct {
    mode: Attack_Mode,
    cooldown: f32,
    use_time: f32
}


Attack_Mode :: enum {
    SINGLE,
    SWING
}