const std = @import("std");
const rl = @import("rl.zig");
const utils = @import("utils.zig");
const game_screen = @import("gamescreen.zig");

pub const GameState = struct {
    allocator: std.mem.Allocator,
    dark_mode: bool,
    p1: game_screen.Player,
    p2: game_screen.Player,
    ball: game_screen.Ball,
    score1: i32 = 0,
    score2: i32 = 0,
    score1String: [10]u8 = [_]u8{0} ** 10,
    score2String: [10]u8 = [_]u8{0} ** 10,
};

export fn gameInit() *anyopaque {
    var allocator = std.heap.page_allocator;
    const game_state = allocator.create(GameState) catch @panic("Out of memory");

    game_state.* = GameState{
        .allocator = allocator,
        .p1 = game_screen.Player.init(.Player1),
        .p2 = game_screen.Player.init(.Player2),
        .ball = game_screen.Ball.init(),
        .dark_mode = utils.env_vars.dark_mode,
    };

    return game_state;
}

// this is called after the dll is rebuilt
export fn gameReload(game_state_ptr: *anyopaque) void {
    const game_state: *GameState = @ptrCast(@alignCast(game_state_ptr));
    game_state.dark_mode = utils.env_vars.dark_mode;
}

export fn gameTick(game_state_ptr: *anyopaque) void {
    const game_state: *GameState = @ptrCast(@alignCast(game_state_ptr));
    _ = game_state;
}

export fn gameDraw(game_state_ptr: *anyopaque) void {
    const game_state: *GameState = @ptrCast(@alignCast(game_state_ptr));
    if (game_state.dark_mode) {
        rl.ClearBackground(rl.BLACK);
    } else {
        rl.ClearBackground(rl.RAYWHITE);
    }
}
