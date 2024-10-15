const std = @import("std");
const builtin = @import("builtin");

const program_name = "Zing";

pub fn build(b: *std.Build) !void {
    const hot_reload = b.option(bool, "hot_reload", "Only hot reload") orelse false;
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const game_dll = b.addSharedLibrary(.{
        .name = "game",
        .root_source_file = b.path("src/game.zig"),
        .target = target,
        .optimize = optimize,
    });

    game_dll.linkLibC();

    const raylib_dep = b.dependency("raylib", .{
        .target = target,
        .optimize = optimize,
        .shared = true,
    });

    game_dll.linkLibrary(raylib_dep.artifact("raylib"));

    switch (target.result.os.tag) {
        .windows => {
            std.debug.print("running on windows\n", .{});
            game_dll.linkSystemLibrary("winmm");
            game_dll.linkSystemLibrary("gdi32");
            game_dll.linkSystemLibrary("opengl32");

            game_dll.defineCMacro("PLATFORM_DESKTOP", null);
        },
        .linux => {
            std.debug.print("running on linux\n", .{});
            game_dll.linkSystemLibrary("GL");
            game_dll.linkSystemLibrary("rt");
            game_dll.linkSystemLibrary("dl");
            game_dll.linkSystemLibrary("m");
            game_dll.linkSystemLibrary("X11");

            game_dll.defineCMacro("PLATFORM_DESKTOP", null);
        },
        .macos => {
            std.debug.print("running on macos\n", .{});
            game_dll.linkFramework("Foundation");
            game_dll.linkFramework("Cocoa");
            game_dll.linkFramework("OpenGL");
            game_dll.linkFramework("CoreAudio");
            game_dll.linkFramework("CoreVideo");
            game_dll.linkFramework("IOKit");

            game_dll.defineCMacro("PLATFORM_DESKTOP", null);
        },
        else => {
            @panic("Unsupported OS");
        },
    }

    b.installArtifact(game_dll);

    if (!hot_reload) {
        const exe = b.addExecutable(.{
            .name = program_name,
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        });

        exe.linkLibC();
        exe.linkLibrary(raylib_dep.artifact("raylib"));

        switch (target.result.os.tag) {
            .windows => {
                std.debug.print("running on windows\n", .{});
                exe.linkSystemLibrary("winmm");
                exe.linkSystemLibrary("gdi32");
                exe.linkSystemLibrary("opengl32");

                exe.defineCMacro("PLATFORM_DESKTOP", null);
            },
            .linux => {
                std.debug.print("running on linux\n", .{});
                exe.linkSystemLibrary("GL");
                exe.linkSystemLibrary("rt");
                exe.linkSystemLibrary("dl");
                exe.linkSystemLibrary("m");
                exe.linkSystemLibrary("X11");

                exe.defineCMacro("PLATFORM_DESKTOP", null);
            },
            .macos => {
                std.debug.print("running on macos\n", .{});
                exe.linkFramework("Foundation");
                exe.linkFramework("Cocoa");
                exe.linkFramework("OpenGL");
                exe.linkFramework("CoreAudio");
                exe.linkFramework("CoreVideo");
                exe.linkFramework("IOKit");

                exe.defineCMacro("PLATFORM_DESKTOP", null);
            },
            else => {
                @panic("Unsupported OS");
            },
        }

        b.installArtifact(exe);

        const run_cmd = b.addRunArtifact(exe);
        const run_step = b.step("run", "Run the app");
        run_step.dependOn(&run_cmd.step);
    }
}
