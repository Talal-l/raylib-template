const std = @import("std");
const builtin = @import("builtin");
const raylib = @import("raylib/build.zig");

const program_name = "TEMPLATE";

pub fn build(b: *std.Build) !void {
    // add flag to indicate we this is a hot reload
    const hot_reload = b.option(bool, "hot_reload", "only build the game shared library") orelse false;

    // Give user option to add their own flags
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Create main executable
    const exe = b.addExecutable(.{
        .name = program_name,
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Create Game Dylib
    const game_dylib = b.addSharedLibrary(.{
        .name = "game",
        .root_source_file = b.path("src/game.zig"),
        .target = target,
        .optimize = optimize,
    });

    // link c libraries
    exe.linkLibC();
    game_dylib.linkLibC();

    // add raylib header files
    exe.addIncludePath(b.path("raylib/src"));
    exe.addIncludePath(b.path("raylib/src/external"));
    exe.addIncludePath(b.path("raylib/src/external/glfw/include"));

    game_dylib.addIncludePath(b.path("raylib/src"));
    game_dylib.addIncludePath(b.path("raylib/src/external"));
    game_dylib.addIncludePath(b.path("raylib/src/external/glfw/include"));

    // add raylib static library
    exe.addObjectFile(switch (target.result.os.tag) {
        .windows => b.path("raylib/zig-out/lib/raylib.lib"),
        .linux => b.path("raylib/zig-out/lib/libraylib.a"),
        .macos => b.path("raylib/zig-out/lib/libraylib.a"),
        .emscripten => b.path("raylib/zig-out/lib/libraylib.a"),
        else => @panic("Unsupported OS"),
    });

    game_dylib.addObjectFile(switch (target.result.os.tag) {
        .windows => b.path("raylib/zig-out/lib/raylib.lib"),
        .linux => b.path("raylib/zig-out/lib/libraylib.a"),
        .macos => b.path("raylib/zig-out/lib/libraylib.a"),
        .emscripten => b.path("raylib/zig-out/lib/libraylib.a"),
        else => @panic("Unsupported OS"),
    });

    // Add OS specific Libraries that raylib uses in the back
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

            game_dylib.linkFramework("Foundation");
            game_dylib.linkFramework("Cocoa");
            game_dylib.linkFramework("OpenGL");
            game_dylib.linkFramework("CoreAudio");
            game_dylib.linkFramework("CoreVideo");
            game_dylib.linkFramework("IOKit");

            game_dylib.defineCMacro("PLATFORM_DESKTOP", null);
        },
        else => {
            @panic("Unsupported OS");
        },
    }

    // add c files in src directory
    // var dir = try std.fs.cwd().openDir("src", .{ .iterate = true });
    // defer if (comptime builtin.zig_version.minor >= 12) dir.close();

    // var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    // defer arena.deinit();

    // const allocator = arena.allocator();
    // var iter = try dir.walk(allocator);
    // defer iter.deinit();

    // while (try iter.next()) |entry| {
    //     if (entry.kind != .file) continue;

    //     _ = std.mem.lastIndexOf(u8, entry.basename, ".c") orelse continue;
    //     const path = try std.fs.path.join(b.allocator, &.{ "src", entry.path });

    //     std.debug.print("path {s}\n", .{path});

    //     exe.addCSourceFile(.{ .file = b.path(path), .flags = &.{} });
    // }

    b.installArtifact(game_dylib);
    if (!hot_reload) {
        b.installArtifact(exe);
        const run_cmd = b.addRunArtifact(exe);
        run_cmd.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }
        const run_step = b.step("run", "Run the app");
        run_step.dependOn(&run_cmd.step);
    }
}
