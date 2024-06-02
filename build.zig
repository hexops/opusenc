const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const opus_dep = b.dependency("opus", .{ .target = target, .optimize = optimize });

    const lib = b.addStaticLibrary(.{
        .name = "opusenc",
        .target = target,
        .optimize = optimize,
    });
    lib.linkLibC();
    lib.linkLibrary(opus_dep.artifact("opus"));
    lib.addIncludePath(b.path("include"));
    lib.addIncludePath(b.path("src"));
    lib.addCSourceFiles(.{ .files = &sources, .flags = &.{
        "-DHAVE_CONFIG_H",
        "-DOUTSIDE_SPEEX",
        "-DRANDOM_PREFIX=MACH",
    } });
    lib.installHeadersDirectory(b.path("include"), "", .{});
    const config_header = b.addConfigHeader(.{ .style = .blank }, .{
        .PACKAGE_NAME = "opusenc",
        .PACKAGE_VERSION = "0.1",
    });
    lib.addConfigHeader(config_header);
    b.installArtifact(lib);
}

const sources = [_][]const u8{
    "src/unicode_support.c",
    "src/opus_header.c",
    "src/opusenc.c",
    "src/resample.c",
    "src/ogg_packer.c",
    "src/picture.c",
};
