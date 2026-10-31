package main

import "core:fmt"
import "core:mem"
import rl "vendor:raylib"

import "data_loading"

main :: proc() {

	when ODIN_DEBUG {
        track: mem.Tracking_Allocator
        mem.tracking_allocator_init(&track, context.allocator)
        context.allocator = mem.tracking_allocator(&track)

        defer {
            if len(track.allocation_map) > 0 {
                fmt.eprintf("=== %v allocations not freed ===\n",
                    len(track.allocation_map))

                for _, entry in track.allocation_map {
                    fmt.eprintf("- %v bytes @ %v\n",
                        entry.size,
                        entry.location,
                    )
                }
            }

            mem.tracking_allocator_destroy(&track)
        }
    }

	document, err := data_loading.yaml_reader("assets/data/characters/frank.yaml", context.allocator)
	if err.type != .NONE {
		fmt.println(err.message)
	}
	data_loading.debug_print(&document)

	fmt.println(data_loading.get_path(&document, "stats", "health"))

	document, err = data_loading.yaml_reader("assets/data/items/potions/healing_potion.yaml", context.allocator)
	if err.type != .NONE {
		fmt.println(err.message)
	}
	data_loading.debug_print(&document)

	fmt.println(data_loading.get_path(&document, "stats", "effects"))

}
