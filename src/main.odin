package main

import "core:fmt"
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

	if !rl.IsTextureValid(frank_texture) {
	    fmt.println("ERROR: Frank texture could not be loaded!")
	    return
	}

	fmt.printf("INFO: Frank texture loaded: %d x %d\n",
	    frank_texture.width,
	    frank_texture.height,
	)

	frame_width := 32
	frame_height := 32
	frame_count := int(frank_texture.width) / frame_width
	frame_index := 0
	frame_timer: f32 = 0
	frame_duration: f32 = 0.15

	for !rl.WindowShouldClose() {
		frame_timer += rl.GetFrameTime()
		if frame_timer >= frame_duration {
			frame_timer -= frame_duration
			frame_index = (frame_index + 1) % frame_count
		}

		source := rl.Rectangle{
			x = f32(frame_index * frame_width),
			y = 0,
			width = f32(frame_width),
			height = f32(frame_height),
		}
		destination := rl.Rectangle{
			x = 384,
			y = 290,
			width = f32(frame_width) * 3,
			height = f32(frame_height) * 3,
		}

		rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)
		rl.DrawText("B.O.N.K.", 320, 190, 48, rl.DARKGRAY)
		rl.DrawText("Odin + raylib", 330, 250, 20, rl.GRAY)
		rl.DrawTexturePro(
		    frank_texture,
		    source,
		    destination,
		    {0, 0},
		    0,
		    rl.WHITE,
		)
		rl.EndDrawing()
	}
}
