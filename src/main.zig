const std = @import("std");
const c = @cImport({
    @cInclude("raylib.h");
});

const screen_w = 400;
const screen_h = 200;

// The main exe doesn't know anything about the GameState structure
// because that information exists inside the DLL, but it doesn't
// need to care. All main cares about is where it exists in memory
// so *anyopaque is just a pointer to a place in memory.
const GameStatePtr = *anyopaque;

// TODO: point these the relevant functions inside the game DLL.
var gameInit: *const fn () GameStatePtr = undefined;
var gameReload: *const fn (GameStatePtr) void = undefined;
var gameTick: *const fn (GameStatePtr) void = undefined;
var gameDraw: *const fn (GameStatePtr) void = undefined;

pub fn main() !void {
    loadGameDll() catch @panic("Failed to load the dylib");
    const game_state = gameInit();
    c.InitWindow(screen_w, screen_h, "Zig Hot-Reload");
    c.SetTargetFPS(60);
    while (!c.WindowShouldClose()) {
        if (c.IsKeyPressed(c.KEY_R)) {
            unloadGameDll() catch unreachable;
            recompileGameDll() catch {
                std.debug.print("Failed to recompile the dylib", .{});
            };
            loadGameDll() catch @panic("Failed to load the dylib");
            gameReload(game_state);
        }
        gameTick(game_state);
        c.BeginDrawing();
        gameDraw(game_state);
        c.EndDrawing();
    }
    c.CloseWindow();
}

var game_dyn_lib: ?std.DynLib = null;
fn loadGameDll() !void {
    if (game_dyn_lib != null) return error.AlreadyLoaded;

    const cwd = try std.fs.cwd().realpathAlloc(std.heap.page_allocator, ".");
    std.log.info("current working directory: {s}", .{cwd});

    var dyn_lib = std.DynLib.open("./zig-out/lib/libgame.dylib") catch {
        return error.OpenDLLFail;
    };

    game_dyn_lib = dyn_lib;

    gameInit = dyn_lib.lookup(@TypeOf(gameInit), "gameInit") orelse return error.LookupFail;
    gameReload = dyn_lib.lookup(@TypeOf(gameReload), "gameReload") orelse return error.LookupFail;
    gameTick = dyn_lib.lookup(@TypeOf(gameTick), "gameTick") orelse return error.LookupFail;
    gameDraw = dyn_lib.lookup(@TypeOf(gameDraw), "gameDraw") orelse return error.LookupFail;
    std.debug.print("Loaded game.dll\n", .{});
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

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    var build_process = std.process.Child.init(&process_args, allocator);
    try build_process.spawn();

    const term = try build_process.wait();
    switch (term) {
        .Exited => |exited| {
            if (exited == 2) return error.RecompileFail;
        },
        else => return,
    }
}
