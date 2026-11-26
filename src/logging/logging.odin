package logging

import "core:log"
import "core:os"
import "core:fmt"

setup_logger :: proc() -> log.Logger {
    when ODIN_DEBUG {
        return log.create_console_logger(.Debug)
    } else {
        mkdir_err := os.mkdir_all("logs")
        if mkdir_err != nil && mkdir_err != .Exist {
            fmt.panicf("Could not create logs directory: %v", mkdir_err)
        }

        log_file, open_err := os.open(
            "logs/game.log",
            {.Write, .Create, .Append},
            os.Permissions_Default_File,
        )
        if open_err != nil {
            fmt.panicf("Could not open log file: %v", open_err)
        }

        return log.create_file_logger(log_file, .Info)
    }
}

destroy_logger :: proc(logger: log.Logger) {
    when ODIN_DEBUG {
        log.destroy_console_logger(logger)
    } else {
        log.destroy_file_logger(logger)
    }
}