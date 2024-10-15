const std = @import("std");
const rl = @import("rl.zig");
const utils = @import("utils.zig");

// importing screens
const game_screen = @import("game_screen/game_screen.zig");
const intro_screen = @import("intro_screen/intro_screen.zig");

// screen enum
const Screen = enum {
    IntroScreen,
    GameScreen,
};

// STATES
pub const GameState = struct {
    intro_screen_state: intro_screen.IntroScreenState,
    game_screen_state: game_screen.GameScreenState,
    current_screen: Screen,
};

export fn gameInit() *anyopaque {
    const game_state = std.heap.page_allocator.create(GameState) catch @panic("Out of memory");

    game_state.* = GameState{
        .game_screen_state = game_screen.GameScreenState.init(),
        .intro_screen_state = intro_screen.IntroScreenState.init(),
        .current_screen = .IntroScreen,
    };

    return game_state;
}

export fn gameReload(game_state_ptr: *anyopaque) void {
    const game_state: *GameState = @ptrCast(@alignCast(game_state_ptr));

    _ = game_state;
}

// TODO: implement full game reload
fn fullGameReload(game_state_ptr: *anyopaque) void {
    const game_state: *GameState = @ptrCast(@alignCast(game_state_ptr));

    _ = game_state;
}

export fn gameTick(game_state_ptr: *anyopaque) void {
    const game_state: *GameState = @ptrCast(@alignCast(game_state_ptr));

    switch (game_state.current_screen) {
        .IntroScreen => {
            game_state.intro_screen_state.update();
            if (game_state.intro_screen_state.done) {
                game_state.current_screen = .GameScreen;
            }
        },
        .GameScreen => game_state.game_screen_state.update(),
    }
}

export fn gameDraw(game_state_ptr: *anyopaque) void {
    const game_state: *GameState = @ptrCast(@alignCast(game_state_ptr));

    switch (game_state.current_screen) {
        .IntroScreen => game_state.intro_screen_state.draw(),
        .GameScreen => game_state.game_screen_state.draw(),
    }
}
