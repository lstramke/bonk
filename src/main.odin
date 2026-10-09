package main

import rl "vendor:raylib"

main :: proc() {
	rl.InitWindow(800, 450, "B.O.N.K.")
	defer rl.CloseWindow()

	frank_texture := rl.LoadTexture("assets/sprites/characters/frank.png")
	defer rl.UnloadTexture(frank_texture)

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)
		rl.DrawText("B.O.N.K.", 320, 190, 48, rl.DARKGRAY)
		rl.DrawText("Odin + raylib", 330, 250, 20, rl.GRAY)
		rl.DrawTexture(frank_texture, 384, 290, rl.WHITE)
		rl.EndDrawing()
	}
}
