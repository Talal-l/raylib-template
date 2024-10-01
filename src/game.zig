const std = @import("std");
const rl = @import("rl.zig");
const game_screen = @import("gamescreen.zig");

const GameState = struct {
    allocator: std.mem.Allocator,
    radius: f32 = 0,
    time: f32 = 0,
};

export fn gameInit() *anyopaque {
    var allocator = std.heap.page_allocator;
    const game_state = allocator.create(GameState) catch @panic("Out of memory");
    game_state.* = GameState{
        .allocator = allocator,
        .radius = 0,
    };
    return game_state;
}

export fn gameReload(game_state_ptr: *anyopaque) void {
    var game_state: *GameState = @ptrCast(@alignCast(game_state_ptr));
    game_state.radius += 1;
}
export fn gameTick(game_state_ptr: *anyopaque) void {
    var game_state: *GameState = @ptrCast(@alignCast(game_state_ptr));
    game_state.time += rl.GetFrameTime();
}

export fn gameDraw(game_state_ptr: *anyopaque) void {
    const game_state: *GameState = @ptrCast(@alignCast(game_state_ptr));
    _ = game_state;
    rl.ClearBackground(rl.BLACK);
}
