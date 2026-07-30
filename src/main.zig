const std = @import("std");
const sodium = @cImport(
    @cInclude("sodium.h")
);

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const allocator = init.arena.allocator();

    var reader_buf: [2048]u8 = undefined;
    var stdin_reader = std.Io.File.stdin().reader(io, &reader_buf);
    const stdin_interface = &stdin_reader.interface;

    const input: []const u8 = 
        try stdin_interface.takeDelimiter('\n') 
        orelse std.process.exit(1);

    const sodium_init: c_int = sodium.sodium_init();
    if (sodium_init < 0) {
        std.process.exit(1);
    }

    const b64_max_len = sodium.sodium_base64_ENCODED_LEN(
        input.len, 
        sodium.sodium_base64_VARIANT_ORIGINAL
    );

    const output = try allocator.alloc(u8, b64_max_len);
    defer allocator.free(output);

    _ = sodium.sodium_bin2base64(
        output.ptr,
        b64_max_len, 
        input.ptr,
        input.len,
        sodium.sodium_base64_VARIANT_ORIGINAL
    );

    std.debug.print("{s}", .{output});
}

