const std = @import("std");
const rl = @import("rl.zig");
const utils = @import("utils.zig");

// Dynamic Library Functions
const GameStatePtr = *anyopaque;
var gameInit: *const fn () GameStatePtr = undefined;
var gameReload: *const fn (GameStatePtr) void = undefined;
var gameTick: *const fn (GameStatePtr) void = undefined;
var gameDraw: *const fn (GameStatePtr) void = undefined;
var gameUnload: *const fn (GameStatePtr) void = undefined;

// Consts
const screen_w = 400;
const screen_h = 400;

pub fn main() !void {
    // INIT WINDOW
    rl.SetWindowMonitor(0);
    rl.InitWindow(screen_w, screen_h, "Zing");
    rl.SetTargetFPS(60);

    // INIT AUDIO
    rl.InitAudioDevice();

    // LOAD .DYLIB/.DLL/.SO
    recompileGameDll() catch {
        std.debug.print("Failed to recompile game.dll", .{});
    };
    loadGameDll() catch @panic("Failed to load game.so");

    const game_state_ptr = gameInit();

    while (!rl.WindowShouldClose()) {
        // QUIT GAME
        if (rl.IsKeyPressed(rl.KEY_Q)) {
            unloadGameDll() catch unreachable;
            rl.CloseWindow();
            return;
        }

        // HOT RELOAD
        if (rl.IsKeyPressed(rl.KEY_R)) {
            unloadGameDll() catch unreachable;
            recompileGameDll() catch {
                std.debug.print("Failed to recompile game.dll", .{});
            };
            loadGameDll() catch @panic("Failed to load game.dll");
            gameReload(game_state_ptr);
        }

        gameTick(game_state_ptr);

        gameDraw(game_state_ptr);
    }

    // CLEAN UP
    gameUnload(game_state_ptr);
    rl.CloseWindow();
}

var game_dyn_lib: ?std.DynLib = null;
const builtin = @import("builtin");
fn loadGameDll() !void {
    std.log.debug("loading game DLL", .{});
    if (game_dyn_lib != null) return error.AlreadyLoaded;

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
    gameUnload = dyn_lib.lookup(@TypeOf(gameUnload), "gameUnload") orelse return error.LookupFail;
    std.log.debug("loaded game DLL", .{});
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
