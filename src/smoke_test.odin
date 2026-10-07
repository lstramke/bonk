package main

import "core:testing"

@(test)
test_smoke :: proc(t: ^testing.T) {
	testing.expect_value(t, 2 + 2, 4)
}
