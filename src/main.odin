
package main

import "core:fmt"
import rl "vendor:raylib"

main :: proc() {
	rl.InitWindow(1280, 704, "B.O.N.K.")
	defer rl.CloseWindow()

	rl.SetTargetFPS(60)

	background_texture := rl.LoadTexture("assets/sprites/backgrounds/grassland.png")
	defer rl.UnloadTexture(background_texture)

	//frank_texture := rl.LoadTexture("assets/sprites/characters/frank.png")
	//defer rl.UnloadTexture(frank_texture)

	stone_texture := rl.LoadTexture("assets/sprites/tiles/stone_block_basic.png")
	defer rl.UnloadTexture(stone_texture)

	dirt_texture := rl.LoadTexture("assets/sprites/tiles/dirt_block_basic.png")
	defer rl.UnloadTexture(dirt_texture)

	grass_texture := rl.LoadTexture("assets/sprites/tiles/grass_block_basic.png")
	defer rl.UnloadTexture(grass_texture)

	lootbox_texture := rl.LoadTexture("assets/sprites/tiles/lootbox_block.png")
	defer rl.UnloadTexture(lootbox_texture)

	if !rl.IsTextureValid(background_texture) {
    	fmt.println("ERROR: Background texture could not be loaded!")
    	return
	}

	if !rl.IsTextureValid(lootbox_texture) {
	    fmt.println("ERROR: Lootbox texture could not be loaded!")
	    return
	}

	//if !rl.IsTextureValid(frank_texture) {
	//	fmt.println("ERROR: Frank texture could not be loaded!")
	//	return
	//}
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

	scale_x := 1280.0 / f32(background_texture.width)
	scale_y := 704.0 / f32(background_texture.height)

	tile_size: f32 = 32.0
	cols := 4

	start_x: f32 = 0.0
	start_y: f32 = 280.0

	frank_scale: f32 = 3.0
	//frank_width := f32(frank_texture.width) * frank_scale
	//frank_height := f32(frank_texture.height) * frank_scale
	middle_x := start_x + 2.0 * tile_size
	//frank_x := middle_x + (tile_size - frank_width) / 2.0
	//frank_y := start_y - frank_height

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)

		rl.DrawTextureEx(
		    background_texture,
		    {0, 0},
		    0.0,
		    scale_x,
		    rl.WHITE,
		)

		rl.DrawText("B.O.N.K.", 320, 40, 48, rl.DARKGRAY)
		rl.DrawText("Odin + raylib", 330, 95, 20, rl.GRAY)

		// Reihe 1: vier Steine
		for col in 0 ..< 41 {
			x := start_x + f32(col)*tile_size
			y := start_y + 3.0*tile_size
			rl.DrawTextureEx(stone_texture, {x, y}, 0.0,
				tile_size/f32(stone_texture.width), rl.WHITE)
		}

		// Reihe 2: vier Erde-Tiles
		for col in 0 ..< 41 {
			x := start_x + f32(col)*tile_size
			y := start_y + 2.0*tile_size
			rl.DrawTextureEx(dirt_texture, {x, y}, 0.0,
				tile_size/f32(dirt_texture.width), rl.WHITE)
		}

		// Reihe 3: Gras
		for col in 0 ..< 41 {
			x := start_x + f32(col)*tile_size
			y := start_y + tile_size
			rl.DrawTextureEx(
				grass_texture, {x, y}, 0.0,
				tile_size/f32(dirt_texture.width), rl.WHITE,
			)
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

		//frank_x += 1
		//// Frank vor der Landschaft zeichnen
		//rl.DrawTextureEx(
		//	frank_texture,
		//	{frank_x, frank_y},
		//	0.0,
		//	frank_scale,
		//	rl.WHITE,
		//)


		//empty_y := frank_y - tile_size

		// Lootbox direkt über dem leeren Block
		//lootbox_x := middle_x
		//lootbox_y := empty_y - tile_size
//
		//rl.DrawTextureEx(
		//    lootbox_texture,
		//    {lootbox_x, lootbox_y},
		//    0.0,
		//    tile_size / f32(lootbox_texture.width),
		//    rl.RAYWHITE,
		//)

		rl.EndDrawing()
	}
}