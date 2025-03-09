const std = @import("std");
const repl = @import("lib/runtime.zig");
const logger = @import("lib/logger.zig");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("samples/Combat (1977).a26", std.fs.File.OpenFlags{
        .mode = .read_only,
    });

    defer file.close();

    const file_reader = file.reader().any();
    var buf_file_reader = std.io.bufferedReader(file_reader);
    var reader = buf_file_reader.reader().any();

    repl.start(&reader) catch |err| {
        logger.errorLog(err);
        unreachable;
    };
}

test "exec_tests" {
    _ = @import("lib/runtime.zig");
}


