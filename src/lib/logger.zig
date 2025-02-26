const std = @import("std");

pub fn simpleLog(msg: []const u8) void {
    std.debug.print("[error] -- {s}\n", .{
        msg
    });
}

pub fn simpleLogWithArgs(comptime msg: []const u8, args: anytype) void {
    std.debug.print("[error] -- " ++ msg, args);
}

pub fn errorLog(msg: anyerror) void {
    std.debug.print("[error] -- {any}\n", .{
        msg
    });
}

