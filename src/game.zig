const std = @import("std");

const GameState = struct {};

export fn gameInit() *anyopaque {
    // TODO: implement
    var allocator = std.heap.c_allocator;
    return allocator.create(GameState) catch @panic("out of memory.");
}

export fn gameReload(game_state_ptr: *anyopaque) void {
    // TODO: implement
    _ = game_state_ptr;
}

export fn gameTick(game_state_ptr: *anyopaque) void {
    // TODO: implement
    _ = game_state_ptr;
}

export fn gameDraw(game_state_ptr: *anyopaque) void {
    // TODO: implement
    _ = game_state_ptr;
}
