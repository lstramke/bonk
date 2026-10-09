package main

import "core:fmt"
import rl "vendor:raylib"

main :: proc() {
	rl.InitWindow(800, 450, "B.O.N.K.")
	defer rl.CloseWindow()

	frank_texture := rl.LoadTexture("assets/sprites/characters/frank.png")
	defer rl.UnloadTexture(frank_texture)

	if !rl.IsTextureValid(frank_texture) {
	    fmt.println("ERROR: Frank texture could not be loaded!")
	    return
	}

	fmt.printf("INFO: Frank texture loaded: %d x %d\n",
	    frank_texture.width,
	    frank_texture.height,
	)

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)
		rl.DrawText("B.O.N.K.", 320, 190, 48, rl.DARKGRAY)
		rl.DrawText("Odin + raylib", 330, 250, 20, rl.GRAY)
		rl.DrawTextureEx(
		    frank_texture,
		    {384, 290},
		    0,
		    3.0,
		    rl.WHITE,
		)
		rl.EndDrawing()
	}
}
