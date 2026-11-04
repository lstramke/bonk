package main

import "core:log"
import "core:fmt"
import mem "core:mem"
import vmem "core:mem/virtual"
import rl "vendor:raylib"

import "data_loading"

main :: proc() {

    ASSET_MODE_MACOS_APP :: #config(ASSET_MODE_MACOS_APP, false)
    mode := data_loading.ASSET_MODE.DEV
    when ASSET_MODE_MACOS_APP {
        mode = data_loading.ASSET_MODE.MACOS_APP
    }

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

    path_resolver, resolver_err := data_loading.create_path_resolver(mode)
    if resolver_err.type != .NONE {
        log.warn(resolver_err.message)
    }
    defer data_loading.delete_path_resolver(&path_resolver)

    fmt.println(path_resolver.asset_root)
    loader := data_loading.create_yaml_data_loader(path_resolver)

	document, err := data_loading.load(&loader, "data/characters/frank.yaml", document_allocator)
	if err.type != .NONE {
		fmt.println(err.message)
	}
	data_loading.debug_print(&document)

    vmem.arena_free_all(&document_arena)

	document, err = data_loading.load(&loader, "maps/grasslands.yaml", document_allocator)
	if err.type != .NONE {
		fmt.println(err.message)
	}
	//data_loading.debug_print(&document)

}
