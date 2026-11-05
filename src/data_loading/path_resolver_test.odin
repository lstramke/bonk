package data_loading

import "core:testing"

Resolve_Path_Testcase :: struct {
    relative_path: string,
    expected_path: string,
    expected_error: Load_Error_Type,
    description: string,
}

@(test)
test_resolve_path :: proc(t: ^testing.T) {
    testcases :: []Resolve_Path_Testcase {
        {
            relative_path = "maps/test.yaml",
            expected_path = "/assets/maps/test.yaml",
            expected_error = .NONE,
            description = "Resolves an allowed asset path",
        },
        {
            relative_path = "",
            expected_error = .INVALID_FILE_PATH,
            description = "Rejects an empty asset path",
        },
        {
            relative_path = "../secret.txt",
            expected_error = .INVALID_FILE_PATH,
            description = "Rejects paths outside the asset root",
        },
        {
            relative_path = "config/settings.yaml",
            expected_error = .INVALID_FILE_PATH,
            description = "Rejects paths outside allowed asset directories",
        },
        {
            relative_path = "/assets/maps/test.yaml",
            expected_error = .INVALID_FILE_PATH,
            description = "Rejects absolute asset paths",
        },
        {
            relative_path = "maps/\x00test.yaml",
            expected_error = .INVALID_FILE_PATH,
            description = "Rejects asset paths containing NUL characters",
        },
    }

    resolver := Path_Resolver{asset_root = "/assets"}

    for testcase in testcases {
        resolved_path, resolver_err := resolve_asset_path(&resolver, testcase.relative_path)

        testing.expect_value(t, resolver_err.type, testcase.expected_error)
        if resolver_err.type == .NONE {
            testing.expect_value(t, resolved_path, testcase.expected_path)
            delete(resolved_path)
        }
    }
}
