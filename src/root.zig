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

/// Универсальная функция парсинга (аналог .parse() в Rust).
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
        // Делегирование пользовательским типам (аналог трейта FromStr)
        .@"struct", .@"union" => if (@hasDecl(T, "parse"))
            T.parse(s)
        else
            @compileError("strparse: type '" ++ @typeName(T) ++ "' must declare 'parse'"),
        else => @compileError("strparse: strparse doesn't support " ++ @typeName(T)),
    };
}
