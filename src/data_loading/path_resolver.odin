package data_loading

import "core:path/filepath"
import "core:os"
import "core:strings"

ASSET_MODE_MACOS_APP :: #config(ASSET_MODE_MACOS_APP, false)

Path_Resolver :: struct {
    asset_root: string,
}

create_path_resolver :: proc() -> (Path_Resolver, Load_Error) {
    executable_dir, err := os.get_executable_directory(context.allocator)
    if err != nil {
        return {}, {
            .EXECUTABLE_DIR_NOT_FOUND, 
            "Error getting executable directory"
        }
    }
    defer delete(executable_dir)

    asset_root : string
    when ASSET_MODE_MACOS_APP {
        asset_root, err = filepath.join({
            executable_dir,
            "../Resources/assets"
        })
    } else {
        asset_root, err = filepath.join({
            executable_dir,
            "../assets"
        })
    }

    if err != nil {
        return {}, {
            .PATH_RESOLUTION_FAILED,
            "Failed to construct asset root path",
        }
    }

    asset_root_abs : string
    asset_root_abs, err = filepath.abs(asset_root)
    delete(asset_root)

    if err != nil {
        return {}, {
            .PATH_RESOLUTION_FAILED,
            "Failed to resolve absolute asset root path",
        }
    }
    
    if !os.is_dir(asset_root_abs) {
        delete(asset_root_abs)
        return {}, {
            .ASSET_ROOT_NOT_FOUND,
            "Asset root directory does not exist",
        }
    }

    return Path_Resolver{asset_root=asset_root_abs}, {}
}

delete_path_resolver :: proc(resolver: ^Path_Resolver) {
    delete(resolver.asset_root)
    resolver^ = {}
}

resolve_asset_path :: proc(
    resolver: ^Path_Resolver,
    relative_path: string,
) -> (string, Load_Error) {
    if resolver == nil || len(resolver.asset_root) == 0 {
        return {}, {
            .ASSET_ROOT_NOT_FOUND,
            "Asset resolver has no configured asset root",
        }
    }

    if len(relative_path) == 0 {
        return {}, {
            .INVALID_FILE_PATH,
            "Asset path must not be empty",
        }
    }

    if filepath.is_abs(relative_path) {
        return {}, {
            .INVALID_FILE_PATH,
            "Asset path must be relative",
        }
    }

    if strings.contains(relative_path, "\x00") {
        return {}, {
            .INVALID_FILE_PATH,
            "Asset path must not contain NUL characters",
        }
    }

    cleaned_path, err := filepath.clean(relative_path)
    if err != nil {
        return {}, {
            .PATH_RESOLUTION_FAILED,
            "Failed to clean relative asset path",
        }
    }
    defer delete(cleaned_path)

    if cleaned_path == "." ||
        strings.has_prefix(cleaned_path, "..") {
        return {}, {
            .INVALID_FILE_PATH,
            "Asset path must remain inside the asset root",
        }
    }

    ALLOWED_ROOTS :: []string{
        "data" + filepath.SEPARATOR_STRING,
        "maps" + filepath.SEPARATOR_STRING,
        "music" + filepath.SEPARATOR_STRING,
        "sounds" + filepath.SEPARATOR_STRING,
        "sprites" + filepath.SEPARATOR_STRING,
    }

    allowed := false
    for root in ALLOWED_ROOTS {
        if strings.has_prefix(cleaned_path, root) {
            allowed = true
            break
        }
    }

    if !allowed {
        return {}, {
            .INVALID_FILE_PATH,
            "Asset path must start with an allowed asset directory",
        }
    }

    resolved_path : string
    resolved_path, err = filepath.join({resolver.asset_root, cleaned_path})
    if err != nil {
        return {}, {
            .PATH_RESOLUTION_FAILED,
            "Failed to construct resolved asset path",
        }
    }

    return resolved_path, {}
}
