
package main

import "core:fmt"
import rl "vendor:raylib"

main :: proc() {
	rl.InitWindow(800, 450, "B.O.N.K.")
	defer rl.CloseWindow()

	frank_texture := rl.LoadTexture("assets/sprites/characters/frank.png")
	defer rl.UnloadTexture(frank_texture)

	stone_texture := rl.LoadTexture("assets/sprites/tiles/stone-block-basic.png")
	defer rl.UnloadTexture(stone_texture)

	dirt_texture := rl.LoadTexture("assets/sprites/tiles/dirt-block-basic.png")
	defer rl.UnloadTexture(dirt_texture)

	grass_texture := rl.LoadTexture("assets/sprites/tiles/grass-block-basic.png")
	defer rl.UnloadTexture(grass_texture)

	lootbox_texture := rl.LoadTexture("assets/sprites/tiles/lootbox-block.png")
	defer rl.UnloadTexture(lootbox_texture)

	if !rl.IsTextureValid(lootbox_texture) {
	    fmt.println("ERROR: Lootbox texture could not be loaded!")
	    return
	}

	if !rl.IsTextureValid(frank_texture) {
		fmt.println("ERROR: Frank texture could not be loaded!")
		return
	}
	if !rl.IsTextureValid(stone_texture) {
		fmt.println("ERROR: Stone tile could not be loaded!")
		return
	}
	if !rl.IsTextureValid(dirt_texture) {
		fmt.println("ERROR: Dirt tile could not be loaded!")
		return
	}
	if !rl.IsTextureValid(grass_texture) {
		fmt.println("ERROR: Grass tile could not be loaded!")
		return
	}

	tile_size: f32 = 32.0
	cols := 4

	start_x :f32= 320.0
	start_y: f32 = 280.0

	frank_scale: f32 = 3.0
	frank_width := f32(frank_texture.width) * frank_scale
	frank_height := f32(frank_texture.height) * frank_scale
	middle_x := start_x + 2.0 * tile_size
	frank_x := middle_x + (tile_size - frank_width) / 2.0
	frank_y := start_y - frank_height

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)

		rl.DrawText("B.O.N.K.", 320, 40, 48, rl.DARKGRAY)
		rl.DrawText("Odin + raylib", 330, 95, 20, rl.GRAY)

		// Reihe 1: vier Steine
		for col in 0 ..< 5 {
			x := start_x + f32(col)*tile_size
			y := start_y + 3.0*tile_size
			rl.DrawTextureEx(stone_texture, {x, y}, 0.0,
				tile_size/f32(stone_texture.width), rl.WHITE)
		}

		// Reihe 2: vier Erde-Tiles
		for col in 0 ..< 5 {
			x := start_x + f32(col)*tile_size
			y := start_y + 2.0*tile_size
			rl.DrawTextureEx(dirt_texture, {x, y}, 0.0,
				tile_size/f32(dirt_texture.width), rl.WHITE)
		}

		// Reihe 3: Gras, Erde, Erde, Erde, Gras
		for col in 0 ..< 5 {
			x := start_x + f32(col)*tile_size
			y := start_y + tile_size
		
			if col == 0 || col == 4 {
				rl.DrawTextureEx(
					grass_texture, {x, y}, 0.0,
					tile_size/f32(grass_texture.width), rl.WHITE,
				)
			} else {
				rl.DrawTextureEx(
					dirt_texture, {x, y}, 0.0,
					tile_size/f32(dirt_texture.width), rl.WHITE,
				)
			}
		}

		// Reihe 4: zwei Gras-Tiles in der Mitte
		for col in 1 ..< 4 {
			x := start_x + f32(col)*tile_size
			y := start_y
		
			rl.DrawTextureEx(
				grass_texture, {x, y}, 0.0,
				tile_size/f32(grass_texture.width), rl.WHITE,
			)
		}

		// Frank vor der Landschaft zeichnen
		rl.DrawTextureEx(
			frank_texture,
			{frank_x, frank_y},
			0.0,
			frank_scale,
			rl.WHITE,
		)

		// Leerer Block direkt über Frank
		empty_x := middle_x
		empty_y := frank_y - tile_size

		rl.DrawRectangle(
		    i32(empty_x),
		    i32(empty_y),
		    i32(tile_size),
		    i32(tile_size),
		    rl.RAYWHITE,
		)

		// Lootbox direkt über dem leeren Block
		lootbox_x := middle_x
		lootbox_y := empty_y - tile_size

		rl.DrawTextureEx(
		    lootbox_texture,
		    {lootbox_x, lootbox_y},
		    0.0,
		    tile_size / f32(lootbox_texture.width),
		    rl.RAYWHITE,
		)

		rl.EndDrawing()
	}
}