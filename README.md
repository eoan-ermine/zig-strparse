# zig-strparse

[![API Reference](https://github.com/eoan-ermine/zig-strparse/actions/workflows/docs.yml/badge.svg?branch=master)](https://github.com/eoan-ermine/zig-strparse/actions/workflows/docs.yml) [![Linux (Zig 0.16.0)](https://github.com/eoan-ermine/zig-strparse/actions/workflows/main.yml/badge.svg?branch=master)](https://github.com/eoan-ermine/zig-strparse/actions/workflows/main.yml) [![Linux (Zig master)](https://github.com/eoan-ermine/zig-strparse/actions/workflows/master.yml/badge.svg?branch=master)](https://github.com/eoan-ermine/zig-strparse/actions/workflows/master.yml)

Generic string parsing library for Zig.

# Installation

For Zig vMAJOR.MINOR.PATCH:

```bash
zig fetch --save https://github.com/eoan-ermine/zig-strparse/archive/refs/tags/<REPLACE ME>.tar.gz
```

For Zig master branch:

```bash
zig fetch --save git+https://github.com/eoan-ermine/zig-strparse
```

Then add the following to `build.zig`:

```zig
const strparse = b.dependency("strparse", .{});
exe.root_module.addImport("strparse", strparse.module("strparse"));
```

# Examples

```zig
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
```
