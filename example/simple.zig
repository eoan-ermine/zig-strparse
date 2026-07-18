const std = @import("std");
const strparse = @import("strparse");

const Point = struct {
    x: i32,
    y: i32,

    pub const ParseError = error{
        InvalidFormat,
    } || std.fmt.ParseIntError;

    pub fn parse(s: []const u8) ParseError!Point {
        var it = std.mem.splitScalar(u8, s, ',');

        const x_str = it.next() orelse return error.InvalidFormat;
        const y_str = it.next() orelse return error.InvalidFormat;

        if (it.next() != null)
            return error.InvalidFormat;

        return .{
            .x = try std.fmt.parseInt(i32, x_str, 10),
            .y = try std.fmt.parseInt(i32, y_str, 10),
        };
    }
};

pub fn main() !void {
    const x = try strparse.parse(i32, "42");
    const y = try strparse.parse(f64, "3.14");
    const z = try strparse.parse(Point, "10,20");

    std.log.info("x: {}", .{x});
    std.log.info("y: {}", .{y});
    std.log.info("z: {},{}", .{ z.x, z.y });
}
