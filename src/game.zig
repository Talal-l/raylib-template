const std = @import("std");
const rl = @import("rl.zig");
const utils = @import("utils.zig");

// IMPORT SCREEN
// TODO: add unloading functions for screens (e.g. sound in game_screen)
const game_screen = @import("game_screen/game_screen.zig");
const intro_screen = @import("intro_screen/intro_screen.zig");
const menu_screen = @import("menu_screen/menu_screen.zig");

// screen enum
const Screen = enum {
    IntroScreen,
    MenuScreen,
    GameScreen,
};

// CONSTS
const BLUR_SHADER_PATH = "assets/shaders/blur.fs";

// STATES
pub const GameState = struct {
    // SCREEN STATES
    intro_screen_state: intro_screen.IntroScreenState,
    menu_screen_state: menu_screen.MenuScreenState,
    game_screen_state: game_screen.GameScreenState,

    // GAME STATE
    current_screen: Screen,
    paused: bool,

    // SHADER UNIFORMS
    u_time: f32,
    u_time_loc: c_int,

    // DRAWING
    target: rl.RenderTexture2D,
    shader: rl.Shader, // this will change to support multiple shaders later on

};

export fn gameInit() *anyopaque {
    const game_state = std.heap.page_allocator.create(GameState) catch @panic("Out of memory");

    game_state.* = GameState{
        .intro_screen_state = intro_screen.IntroScreenState.init(),
        .menu_screen_state = menu_screen.MenuScreenState.init(),
        .game_screen_state = game_screen.GameScreenState.init(),

        .current_screen = .IntroScreen,
        .u_time = 0.0,
        .u_time_loc = 0,
        .paused = false,

        .target = rl.LoadRenderTexture(rl.GetScreenWidth(), rl.GetScreenHeight()),
        .shader = rl.LoadShader(0, BLUR_SHADER_PATH),
    };

    game_state.u_time_loc = rl.GetShaderLocation(game_state.shader, "u_time");

    return game_state;
}

export fn gameReload(game_state_ptr: *anyopaque) void {
    const game_state: *GameState = @ptrCast(@alignCast(game_state_ptr));

    rl.UnloadRenderTexture(game_state.target);
    rl.UnloadShader(game_state.shader);

    game_state.target = rl.LoadRenderTexture(rl.GetScreenWidth(), rl.GetScreenHeight());
    game_state.shader = rl.LoadShader(0, BLUR_SHADER_PATH);
}

export fn gameTick(game_state_ptr: *anyopaque) void {
    const game_state: *GameState = @ptrCast(@alignCast(game_state_ptr));

    // PAUSE
    if (rl.IsKeyPressed(rl.KEY_P)) game_state.paused = !game_state.paused;
    if (game_state.paused) return;

    game_state.u_time += rl.GetFrameTime();

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

    // DRAW STATE TO TEXTURE
    rl.BeginTextureMode(game_state.target);
    {
        rl.ClearBackground(rl.RAYWHITE);
        switch (game_state.current_screen) {
            .IntroScreen => game_state.intro_screen_state.draw(),
            .MenuScreen => game_state.menu_screen_state.draw(),
            .GameScreen => game_state.game_screen_state.draw(),
        }

        // DRAW PAUSE SIGN
        if (game_state.paused) {
            rl.DrawRectangle(rl.GetScreenWidth() - 40, 10, 15, 30, rl.WHITE);
            rl.DrawRectangle(rl.GetScreenWidth() - 20, 10, 15, 30, rl.WHITE);
        }
    }
    rl.EndTextureMode();

    // APPLY SHADERS
    rl.BeginDrawing();
    {
        if (game_state.paused) {
            rl.BeginShaderMode(game_state.shader);
            {
                rl.SetShaderValue(
                    game_state.shader,
                    game_state.u_time_loc,
                    &game_state.u_time,
                    rl.SHADER_UNIFORM_FLOAT,
                );
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
            rl.DrawTextureRec(
                game_state.target.texture,
                .{ .x = 0, .y = 0, .width = @as(f32, @floatFromInt(game_state.target.texture.width)), .height = @as(f32, @floatFromInt(-game_state.target.texture.height)) },
                .{ .x = 0, .y = 0 },
                rl.WHITE,
            );
        }
    }
    rl.EndDrawing();
}

export fn gameUnload(game_state_ptr: *anyopaque) void {
    const game_state: *GameState = @ptrCast(@alignCast(game_state_ptr));

    rl.UnloadRenderTexture(game_state.target);
    rl.UnloadShader(game_state.shader);
}
