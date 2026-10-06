package main

import rl "vendor:raylib"

main :: proc() {
	rl.InitWindow(800, 450, "B.O.N.K.")
	defer rl.CloseWindow()

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)
		rl.DrawText("B.O.N.K.", 320, 190, 48, rl.DARKGRAY)
		rl.DrawText("Odin + raylib", 330, 250, 20, rl.GRAY)
		rl.EndDrawing()
	}
}
