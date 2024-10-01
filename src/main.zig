const std = @import("std");
const rl = @import("rl.zig");

const screen_w = 200;
const screen_h = 200;

const GameStatePtr = *anyopaque;

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
        if (rl.IsKeyPressed(rl.KEY_X) or rl.IsKeyPressed(rl.KEY_Q)) {
            unloadGameDll() catch unreachable;
            rl.CloseWindow();
            return;
        }
        if (rl.IsKeyPressed(rl.KEY_R)) {
            // it should never unload a dll that isn't there so unreachable is there to state that intent
            unloadGameDll() catch unreachable;
            recompileGameDll() catch {
                std.debug.print("Failed to recompile game.dll", .{});
            };
            loadGameDll() catch @panic("Failed to load game.dll");
            gameReload(game_state);
        }

        rl.BeginDrawing();
        gameDraw(game_state);
        rl.EndDrawing();
    }
    rl.CloseWindow();
}

var game_dyn_lib: ?std.DynLib = null;
const builtin = @import("builtin");
fn loadGameDll() !void {
    if (game_dyn_lib != null) return error.AlreadyLoaded;

    var dyn_lib = switch (builtin.target.os.tag) {
        .macos => std.DynLib.open("zig-out/lib/libgame.dylib"),
        .windows => std.DynLib.open("zig-out/lib/libgame.dll"),
        .linux => std.DynLib.open("zig-out/lib/libgame.so"),
        else => return error.UnsupportedOS,
    } catch {
        return error.OpenFail;
    };

    std.debug.print("dyn_lib: {any}", .{dyn_lib});

    game_dyn_lib = dyn_lib;

    gameInit = dyn_lib.lookup(@TypeOf(gameInit), "gameInit") orelse return error.LookupFail;
    gameReload = dyn_lib.lookup(@TypeOf(gameReload), "gameReload") orelse return error.LookupFail;
    gameTick = dyn_lib.lookup(@TypeOf(gameTick), "gameTick") orelse return error.LookupFail;
    gameDraw = dyn_lib.lookup(@TypeOf(gameDraw), "gameDraw") orelse return error.LookupFail;
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
    const process_args = [_][]const u8{
        "zig",
        "build",
        "-Dhot_reload=true",
    };

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
