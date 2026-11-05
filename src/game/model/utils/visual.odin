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