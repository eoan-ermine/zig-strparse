const std = @import("std");

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    const strparse = b.addModule("strparse", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
    });

    const strparse_tests = b.addTest(.{
        .root_module = strparse,
    });
    const run_strparse_tests = b.addRunArtifact(strparse_tests);
    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_strparse_tests.step);

    const example_step = b.step("examples", "Build examples");
    const simple_example = b.addExecutable(.{
        .name = "simple",
        .root_module = b.createModule(.{ .root_source_file = b.path("example/simple.zig"), .target = target, .optimize = optimize, .imports = &.{
            .{ .name = "strparse", .module = strparse },
        } }),
    });
    const install_simple_example = b.addInstallArtifact(simple_example, .{});
    example_step.dependOn(&simple_example.step);
    example_step.dependOn(&install_simple_example.step);
}
