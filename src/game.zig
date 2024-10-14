const std = @import("std");
const rl = @import("rl.zig");
const utils = @import("utils.zig");
const game_screen = @import("game_screen/game_screen.zig");

pub const GameState = struct {
    allocator: std.mem.Allocator,
    // GAME SCREEN STATE
    game_screen_state: game_screen.GameScreenState,
    // STATE FOR THE NEXT STATE
};

export fn gameInit() *anyopaque {
    var allocator = std.heap.page_allocator;
    const game_state = allocator.create(GameState) catch @panic("Out of memory");

    game_state.* = GameState{
        .allocator = allocator,
        .game_screen_state = game_screen.GameScreenState.init(),
    };

    return game_state;
}

// this is called after the dll is rebuilt
export fn gameReload(game_state_ptr: *anyopaque) void {
    const game_state: *GameState = @ptrCast(@alignCast(game_state_ptr));
    game_state.* = GameState{
        .allocator = game_state.allocator,
        .game_screen_state = game_screen.GameScreenState.init(),
    };
}

export fn gameTick(game_state_ptr: *anyopaque) void {
    const game_state: *GameState = @ptrCast(@alignCast(game_state_ptr));
    game_state.game_screen_state.update();
}

export fn gameDraw(game_state_ptr: *anyopaque) void {
    const game_state: *GameState = @ptrCast(@alignCast(game_state_ptr));
    game_state.game_screen_state.draw();
    rl.ClearBackground(rl.BLACK);
}
