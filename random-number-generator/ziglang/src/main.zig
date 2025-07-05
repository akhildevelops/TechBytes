const std = @import("std");
const rng = struct {
    seed: u64,
    fn next(self: *@This()) ?u64 {
        self.seed ^= self.seed << 13;
        self.seed ^= self.seed >> 17;
        self.seed ^= self.seed << 5;
        return self.seed;
    }
};
pub fn main() !void {
    const stdout = std.io.getStdOut();
    const random_file = try std.fs.openFileAbsolute("/dev/random", .{});
    var random_file_reader = random_file.reader();
    defer random_file.close();
    var buffer: [8]u8 = undefined;
    _ = try random_file_reader.readAll(&buffer);
    const number: u64 = @bitCast(buffer);
    var r = rng{ .seed = number };
    const stdout_writer = stdout.writer();
    var BufWriter = std.io.BufferedWriter(8192 * 3, @TypeOf(stdout_writer)){ .unbuffered_writer = stdout_writer };
    const writer = BufWriter.writer();
    while (r.next()) |val| {
        try writer.print("{d}", .{val});
    }
}
