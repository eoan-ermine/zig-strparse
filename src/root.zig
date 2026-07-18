const std = @import("std");

pub fn ParseError(comptime T: type) type {
    return switch (@typeInfo(T)) {
        .int => std.fmt.ParseIntError,
        .float => std.fmt.ParseFloatError,
        .@"enum" => error{InvalidEnumTag},
        .bool => error{ParseBoolError},
        .@"struct", .@"union" => if (@hasDecl(T, "ParseError"))
            T.ParseError
        else
            @compileError("strparse: type '" ++ @typeName(T) ++ "' must declare 'ParseError'"),
        else => @compileError("strparse: strparse doesn't support: " ++ @typeName(T)),
    };
}

pub fn parse(comptime T: type, s: []const u8) ParseError(T)!T {
    return switch (@typeInfo(T)) {
        .int => std.fmt.parseInt(T, s, 10),
        .float => std.fmt.parseFloat(T, s),
        .@"enum" => std.meta.stringToEnum(T, s) orelse error.InvalidEnumTag,
        .bool => if (std.ascii.eqlIgnoreCase(s, "true"))
            true
        else if (std.ascii.eqlIgnoreCase(s, "false"))
            false
        else
            error.ParseBoolError,
        .@"struct", .@"union" => if (@hasDecl(T, "parse"))
            T.parse(s)
        else
            @compileError("strparse: type '" ++ @typeName(T) ++ "' must declare 'parse'"),
        else => @compileError("strparse: strparse doesn't support " ++ @typeName(T)),
    };
}

test "parse_int" {
    try std.testing.expectEqual(-10, try parse(i32, "-10"));
    try std.testing.expectEqual(10, try parse(i32, "+10"));
    try std.testing.expectEqual(10, try parse(i32, "10"));
    try std.testing.expectError(error.InvalidCharacter, parse(i32, "not-int"));
}

test "parse_float" {
    try std.testing.expectEqual(-2.5, try parse(f32, "-2.5"));
    try std.testing.expectEqual(2.5, try parse(f32, "+2.5"));
    try std.testing.expectEqual(2.5, try parse(f32, "2.5"));
    try std.testing.expectError(error.InvalidCharacter, parse(f32, "not-float"));
}

test "parse_enum" {
    const E1 = enum {
        A,
        B,
    };
    try std.testing.expectEqual(E1.A, try parse(E1, "A"));
    try std.testing.expectEqual(E1.B, try parse(E1, "B"));
    try std.testing.expectError(error.InvalidEnumTag, parse(E1, "C"));
}

test "parse_bool" {
    try std.testing.expectEqual(true, try parse(bool, "true"));
    try std.testing.expectEqual(false, try parse(bool, "false"));
    try std.testing.expectError(error.ParseBoolError, parse(bool, "not-bool"));
}
