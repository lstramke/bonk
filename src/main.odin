package main

import rl "vendor:raylib"

main :: proc() {
	rl.InitWindow(800, 450, "B.O.N.K.")
	defer rl.CloseWindow()

	frank_texture := rl.LoadTexture("assets/sprites/characters/frank.png")
	if !rl.IsTextureReady(frank_texture) {
		rl.UnloadTexture(frank_texture)
		frank_texture = rl.LoadTexture("../assets/sprites/characters/frank.png")
	}
	defer rl.UnloadTexture(frank_texture)

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)
		rl.DrawText("B.O.N.K.", 320, 190, 48, rl.DARKGRAY)
		rl.DrawText("Odin + raylib", 330, 250, 20, rl.GRAY)
		if rl.IsTextureReady(frank_texture) {
			rl.DrawTextureEx(frank_texture, rl.Vector2{368, 285}, 0, 4, rl.WHITE)
		} else {
			rl.DrawText("frank.png konnte nicht geladen werden", 235, 330, 20, rl.RED)
		}
		rl.EndDrawing()
	}
}
