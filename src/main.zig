const std = @import("std");
const rl = @import("rl.zig");
const utils = @import("utils.zig");

const GameStatePtr = *anyopaque;

const screen_w = 200;
const screen_h = 200;

var gameInit: *const fn () GameStatePtr = undefined;
var gameReload: *const fn (GameStatePtr) void = undefined;
var gameTick: *const fn (GameStatePtr) void = undefined;
var gameDraw: *const fn (GameStatePtr) void = undefined;

pub fn main() !void {
    loadGameDll() catch @panic("Failed to load game.so");

    const game_state = gameInit();

    rl.SetWindowMonitor(0);
    rl.InitWindow(screen_w, screen_h, "Pong");
    rl.SetTargetFPS(60);

    while (!rl.WindowShouldClose()) {
        // if quit_key is pressed then quit the application
        if (rl.IsKeyPressed(utils.env_vars.quit_key)) {
            unloadGameDll() catch unreachable;
            rl.CloseWindow();
            return;
        }

        // if hot_reload key is pressed then recompile the DLL and
        if (rl.IsKeyPressed(utils.env_vars.hot_reload_key)) {
            unloadGameDll() catch unreachable;
            recompileGameDll() catch {
                std.debug.print("Failed to recompile game.dll", .{});
            };
            loadGameDll() catch @panic("Failed to load game.dll");
            gameReload(game_state);
        }

        // raylib logic
        rl.BeginDrawing();
        gameDraw(game_state);
        rl.EndDrawing();
    }

    // clean up after finishing
    rl.CloseWindow();
}

var game_dyn_lib: ?std.DynLib = null;
const builtin = @import("builtin");
fn loadGameDll() !void {
    std.log.debug("reloading game DLL", .{});
    if (game_dyn_lib != null) return error.AlreadyLoaded;

    // loading environ variables from env.json
    const file = try std.fs.cwd().openFile("src/env.json", .{});
    defer file.close();

    var buffer: [1000]u8 = undefined;
    const bytes_read = try file.read(&buffer);

    const parsed = try std.json.parseFromSlice(utils.EnvVars, std.heap.page_allocator, buffer[0..bytes_read], .{});
    parsed.deinit();
    utils.env_vars = parsed.value;

    var dyn_lib = switch (builtin.target.os.tag) {
        .macos => std.DynLib.open("zig-out/lib/libgame.dylib"),
        .windows => std.DynLib.open("zig-out/lib/libgame.dll"),
        .linux => std.DynLib.open("zig-out/lib/libgame.so"),
        else => return error.UnsupportedOS,
    } catch {
        return error.OpenFail;
    };

    game_dyn_lib = dyn_lib;

    gameInit = dyn_lib.lookup(@TypeOf(gameInit), "gameInit") orelse return error.LookupFail;
    gameReload = dyn_lib.lookup(@TypeOf(gameReload), "gameReload") orelse return error.LookupFail;
    gameTick = dyn_lib.lookup(@TypeOf(gameTick), "gameTick") orelse return error.LookupFail;
    gameDraw = dyn_lib.lookup(@TypeOf(gameDraw), "gameDraw") orelse return error.LookupFail;
    std.log.debug("Reloaded game DLL", .{});
}

fn unloadGameDll() !void {
    if (game_dyn_lib) |*dyn_lib| {
        dyn_lib.close();
        game_dyn_lib = null;
    } else {
        return error.AlreadyUnloaded;
    }
}

fn recompileGameDll() !void {
    // defining process arguments
    const process_args = [_][]const u8{
        "zig",
        "build",
        "-Dhot_reload=true",
    };

    // recreating the game shared library
    var build_process = std.process.Child.init(&process_args, std.heap.page_allocator);
    try build_process.spawn();

    const term = try build_process.wait();
    switch (term) {
        .Exited => |exited| {
            if (exited == 2) return error.RecompileFail;
        },
        else => return,
    }
}
