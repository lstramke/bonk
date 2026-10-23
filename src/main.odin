package main

import "core:fmt"
import rl "vendor:raylib"

main :: proc() {
	rl.InitWindow(1280, 704, "B.O.N.K.")
	defer rl.CloseWindow()

	drink_potion_texture := rl.LoadTexture("assets/sprites/items/weapons/pistol.png")
	defer rl.UnloadTexture(drink_potion_texture)

	heal_drink_animation := rl.LoadTexture("assets/sprites/items/weapons/magic_orb.png")
	defer rl.UnloadTexture(heal_drink_animation)

	potion_frame_width := 32
	potion_frame_height := 32
	potion_frame_count := int(heal_drink_animation.width) / potion_frame_width

	potion_frame_index := 0
	potion_frame_timer: f32 = -10
	potion_frame_duration: f32 = 0.1
	potion_animation_finished := false

	throw_potion_texture := rl.LoadTexture("assets/sprites/items/weapons/magic_orb_recharge.png")
	defer rl.UnloadTexture(throw_potion_texture)

	slow_use_animation := rl.LoadTexture("assets/sprites/items/weapons/magic_orb.png")
	defer rl.UnloadTexture(slow_use_animation)

	slow_impact_animation := rl.LoadTexture("assets/sprites/items/weapons/magic_orb_recharge.png")
	defer rl.UnloadTexture(slow_impact_animation)

	slow_potion_frame_count := int(slow_impact_animation.width) / potion_frame_width
	slow_potion_frame_index := 0
	slow_potion_frame_timer: f32 = -10
	slow_potion_frame_duration: f32 = 0.1
	slow_potion_animation_finished := false

	sword_texture := rl.LoadTexture("assets/sprites/items/weapons/sword.png")
	defer rl.UnloadTexture(sword_texture) 

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

	rl.SetTargetFPS(60)

	background_texture := rl.LoadTexture("assets/sprites/backgrounds/grassland.png")
	defer rl.UnloadTexture(background_texture)

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
	frank_width := f32(frank_texture.width) * frank_scale
	frank_height := f32(frank_texture.height) * frank_scale
	middle_x := start_x + 2.0 * tile_size
	frank_x := middle_x + 100.0 + (tile_size - frank_width) / 2.0
	frank_y := start_y - frank_height

	for !rl.WindowShouldClose() {
		frame_timer += rl.GetFrameTime()
		if frame_timer >= frame_duration {
			frame_timer -= frame_duration
			frame_index = (frame_index + 1) % frame_count
		}

		if !potion_animation_finished {
		    potion_frame_timer += rl.GetFrameTime()

		    if potion_frame_timer >= potion_frame_duration {
		        potion_frame_timer -= potion_frame_duration

		        if potion_frame_index < potion_frame_count - 1 {
		            potion_frame_index += 1
		        } else {
		            potion_animation_finished = true
		        }
		    }
		}

		if ! slow_potion_animation_finished {
			slow_potion_frame_timer += rl.GetFrameTime()

			if slow_potion_frame_timer >= slow_potion_frame_duration {
				slow_potion_frame_timer -= slow_potion_frame_duration

				if slow_potion_frame_index < slow_potion_frame_count - 1 {
					slow_potion_frame_index += 1
				} else {
					slow_potion_animation_finished = true
				}
			}
		}

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

		frank_x += 1

		if frank_x > 1280 {
			frank_x = 0
		}
		// Frank vor der Landschaft zeichnen
		rl.DrawTextureEx(
			drink_potion_texture,
			{frank_x, frank_y},
			0.0,
			frank_scale,
			rl.WHITE,
		)

		potion_source := rl.Rectangle{
		    x = f32(potion_frame_index * potion_frame_width),
		    y = 0,
		    width = f32(potion_frame_width),
		    height = f32(potion_frame_height),
		}

		potion_destination := rl.Rectangle{
		    x = frank_x - 12,
		    y = frank_y + 12,
		    width = f32(potion_frame_width),
		    height = f32(potion_frame_height),
		}

		rl.DrawTexturePro(
		    heal_drink_animation,
		    potion_source,
		    potion_destination,
		    {0, 0},
		    0.0,
		    rl.WHITE,
		)

		slow_potion_source := rl.Rectangle{
		    x = f32(slow_potion_frame_index * potion_frame_width),
		    y = 0,
		    width = f32(potion_frame_width),
		    height = f32(potion_frame_height),
		}

		slow_potion_destination := rl.Rectangle{
		    x = frank_x - 30,
		    y = frank_y - 30,
		    width = f32(potion_frame_width),
		    height = f32(potion_frame_height),
		}

		rl.DrawTexturePro(
			slow_impact_animation,
			slow_potion_source,
			slow_potion_destination,
			{0, 0},
			0.0,
			rl.WHITE
		)


		empty_y := frank_y - tile_size

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