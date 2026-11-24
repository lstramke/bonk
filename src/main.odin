package main

import "core:log"
import "core:fmt"
import mem "core:mem"
import vmem "core:mem/virtual"
import rl "vendor:raylib"

import "data_loading"
import "game/model/effects"
import "game/parsers"

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

    logger := log.create_console_logger()
    context.logger = logger
    defer log.destroy_console_logger(logger)

    ASSET_MODE_MACOS_APP :: #config(ASSET_MODE_MACOS_APP, false)
    mode := data_loading.ASSET_MODE.DEV
    when ASSET_MODE_MACOS_APP {
        mode = data_loading.ASSET_MODE.MACOS_APP
    }

    document_arena: vmem.Arena
    vmem_err := vmem.arena_init_growing(&document_arena)
    assert(vmem_err == nil, "error initilaizing document arena")
    document_allocator := vmem.arena_allocator(&document_arena)
    defer vmem.arena_destroy(&document_arena)

    definition_arena: vmem.Arena
    vmem_err = vmem.arena_init_growing(&definition_arena)
    assert(vmem_err == nil, "error initializing definition arena")
    definition_allocator := vmem.arena_allocator(&definition_arena)
    defer vmem.arena_destroy(&definition_arena)

    path_resolver, resolver_err := data_loading.create_path_resolver(mode)
    if resolver_err.type != .NONE {
        log.warn(resolver_err.message)
    }
    defer data_loading.delete_path_resolver(&path_resolver)

    loader := data_loading.create_yaml_data_loader(path_resolver)

    document, err := data_loading.load(
        &loader,
        "data/effects/instant_heal.yaml",
        document_allocator,
    )
    if err.type != .NONE {
        log.error(err.message)
        return
    }
    data_loading.debug_print(&document)
    
    effect, parse_err := parsers.parse_effect(&document, definition_allocator)
    if parse_err.type != .NONE {
        log.error(parse_err.message)
        return
    }

    document2, err2 := data_loading.load(
        &loader,
        "data/effects/heal_over_time.yaml",
        document_allocator,
    )
    if err2.type != .NONE {
        log.error(err2.message)
        return
    }
    data_loading.debug_print(&document2)
    effect2, parse_err2 := parsers.parse_effect(&document2, definition_allocator)
    if parse_err2.type != .NONE {
        log.error(parse_err2.message)
        return
    }

    document3, err3 := data_loading.load(
        &loader,
        "data/effects/instant_slow.yaml",
        document_allocator,
    )
    if err3.type != .NONE {
        log.error(err3.message)
        return
    }
    data_loading.debug_print(&document3)
    effect3, parse_err3 := parsers.parse_effect(&document3, definition_allocator)
    if parse_err3.type != .NONE {
        log.error(parse_err3.message)
        return
    }

    vmem.arena_free_all(&document_arena)
    fmt.println(effect)
    fmt.println(effect2)
    fmt.println(effect3)
    vmem.arena_free_all(&definition_arena)
}
