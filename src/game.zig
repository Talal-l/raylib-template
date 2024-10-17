const std = @import("std");
const rl = @import("rl.zig");
const utils = @import("utils.zig");

// importing screens
const game_screen = @import("game_screen/game_screen.zig");
const intro_screen = @import("intro_screen/intro_screen.zig");
const menu_screen = @import("menu_screen/menu_screen.zig");

// screen enum
const Screen = enum {
    IntroScreen,
    MenuScreen,
    GameScreen,
};

// STATES
pub const GameState = struct {
    intro_screen_state: intro_screen.IntroScreenState,
    menu_screen_state: menu_screen.MenuScreenState,
    game_screen_state: game_screen.GameScreenState,
    current_screen: Screen,
    target: rl.RenderTexture2D,
    shader: rl.Shader, // this will change to support multiple shaders later on
    enable_shaders: bool,
    u_time: f32, // Shader uniform
};

export fn gameInit() *anyopaque {
    const game_state = std.heap.page_allocator.create(GameState) catch @panic("Out of memory");

    game_state.* = GameState{
        .target = rl.LoadRenderTexture(rl.GetScreenWidth(), rl.GetScreenHeight()),
        .shader = rl.LoadShader(0, "src/resources/shaders/blur.fs"),
        .intro_screen_state = intro_screen.IntroScreenState.init(),
        .menu_screen_state = menu_screen.MenuScreenState.init(),
        .game_screen_state = game_screen.GameScreenState.init(),
        .current_screen = .IntroScreen,
        .enable_shaders = false,
        .u_time = 0.0,
    };

    return game_state;
}

export fn gameReload(game_state_ptr: *anyopaque) void {
    const game_state: *GameState = @ptrCast(@alignCast(game_state_ptr));

    _ = game_state;
}

// TODO: implement full game reload
fn __fullGameReload(game_state_ptr: *anyopaque) void {
    const game_state: *GameState = @ptrCast(@alignCast(game_state_ptr));

    _ = game_state;
}

export fn gameTick(game_state_ptr: *anyopaque) void {
    const game_state: *GameState = @ptrCast(@alignCast(game_state_ptr));

    switch (game_state.current_screen) {
        .IntroScreen => {
            game_state.intro_screen_state.update();
            if (game_state.intro_screen_state.done) {
                game_state.current_screen = .MenuScreen;
            }
        },
        .MenuScreen => {
            game_state.menu_screen_state.update();
            if (game_state.menu_screen_state.done) {
                game_state.current_screen = .GameScreen;
            }
        },
        .GameScreen => game_state.game_screen_state.update(),
    }
}

export fn gameDraw(game_state_ptr: *anyopaque) void {
    const game_state: *GameState = @ptrCast(@alignCast(game_state_ptr));

    rl.BeginTextureMode(game_state.target);
    {
        rl.ClearBackground(rl.RAYWHITE);
        switch (game_state.current_screen) {
            .IntroScreen => game_state.intro_screen_state.draw(),
            .MenuScreen => game_state.menu_screen_state.draw(),
            .GameScreen => game_state.game_screen_state.draw(),
        }
    }
    rl.EndTextureMode();

    rl.BeginDrawing();
    {
        if (game_state.enable_shaders) {
            rl.BeginShaderMode(game_state.shader);
            {
                game_state.u_time += rl.GetFrameTime();
                const u_time_loc = rl.GetShaderLocation(game_state.shader, "u_time");
                rl.SetShaderValue(game_state.shader, u_time_loc, &game_state.u_time, rl.SHADER_UNIFORM_FLOAT);
                // flip the coordinates as openGL defaults (left-bottom)
                rl.DrawTextureRec(
                    game_state.target.texture,
                    .{ .x = 0, .y = 0, .width = @as(f32, @floatFromInt(game_state.target.texture.width)), .height = @as(f32, @floatFromInt(-game_state.target.texture.height)) },
                    .{ .x = 0, .y = 0 },
                    rl.WHITE,
                );
            }
            rl.EndShaderMode();
        } else {
            rl.DrawTextureRec(game_state.target.texture, .{ .x = 0, .y = 0, .width = @as(f32, @floatFromInt(game_state.target.texture.width)), .height = @as(f32, @floatFromInt(-game_state.target.texture.height)) }, .{ .x = 0, .y = 0 }, rl.WHITE);
        }
    }
    rl.EndDrawing();
}

fn gameEnd(game_state_ptr: *anyopaque) void {
    const game_state: *GameState = @ptrCast(@alignCast(game_state_ptr));

    rl.UnloadRenderTexture(game_state.target);
    rl.UnloadShader(game_state.shader);
}
