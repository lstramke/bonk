package main

import "core:fmt"
import mem "core:mem"
import vmem "core:mem/virtual"
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

    document_arena: vmem.Arena
    vmem_err := vmem.arena_init_growing(&document_arena)
    assert(vmem_err == nil, "error initilaizing document arena")
    document_allocator := vmem.arena_allocator(&document_arena)
    defer vmem.arena_destroy(&document_arena)

    loader := data_loading.Data_Loader{data_loading.yaml_reader}

	document, err := data_loading.load_data(&loader, "assets/data/characters/frank.yaml", document_allocator)
	if err.type != .NONE {
		fmt.println(err.message)
	}
	data_loading.debug_print(&document)
	fmt.println(data_loading.get_path(&document, "stats", "health"))

    vmem.arena_free_all(&document_arena)

	document, err = data_loading.load_data(&loader, "assets/data/items/potions/healing_potion.yaml", document_allocator)
	if err.type != .NONE {
		fmt.println(err.message)
	}
	data_loading.debug_print(&document)

	fmt.println(data_loading.get_path(&document, "stats", "effects"))

    test_array := make([dynamic]int, context.allocator)
    defer delete(test_array)

    append(&test_array, 10)
    append(&test_array, 20)
    append(&test_array, 30)

}
