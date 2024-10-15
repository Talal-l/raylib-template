const std = @import("std");
const rl = @import("rl.zig");
const utils = @import("utils.zig");

// Dynamic Library Functions
const GameStatePtr = *anyopaque;
var gameInit: *const fn () GameStatePtr = undefined;
var gameReload: *const fn (GameStatePtr) void = undefined;
var gameTick: *const fn (GameStatePtr) void = undefined;
var gameDraw: *const fn (GameStatePtr) void = undefined;

// Consts
const screen_w = 400;
const screen_h = 400;

// Vars
var paused = false;
var enable_shaders = true;

// Shader uniform
var u_time: f32 = 0.0;

pub fn main() !void {
    // recompile so that initial run can have changes
    rl.SetWindowMonitor(0);
    rl.InitWindow(screen_w, screen_h, "Zing");
    rl.SetTargetFPS(60);

    recompileGameDll() catch {
        std.debug.print("Failed to recompile game.dll", .{});
    };
    loadGameDll() catch @panic("Failed to load game.so");

    const game_state = gameInit();
    const shader = rl.LoadShader(0, "src/resources/shaders/frag3.fs");
    const target = rl.LoadRenderTexture(rl.GetScreenWidth(), rl.GetScreenHeight());

    while (!rl.WindowShouldClose()) {

        // quit game on env.quit_key
        if (rl.IsKeyPressed(rl.KEY_Q)) {
            unloadGameDll() catch unreachable;
            rl.CloseWindow();
            return;
        }

        // if hot_reload key is pressed then recompile the DLL and
        if (rl.IsKeyPressed(rl.KEY_R)) {
            unloadGameDll() catch unreachable;
            recompileGameDll() catch {
                std.debug.print("Failed to recompile game.dll", .{});
            };
            loadGameDll() catch @panic("Failed to load game.dll");
            gameReload(game_state);
        }

        if (rl.IsKeyPressed(rl.KEY_E)) {
            enable_shaders = !enable_shaders;
        }

        if (rl.IsKeyPressed(rl.KEY_P)) {
            paused = !paused;
        }

        // update the game_state
        if (!paused) {
            gameTick(game_state);
        }

        // draw to texture
        rl.BeginTextureMode(target);
        {
            rl.ClearBackground(rl.RAYWHITE);
            gameDraw(game_state);
        }
        rl.EndTextureMode();

        // TODO: move all drawing logic into game.zig to have it hot reload
        // display the texture with the given shader
        rl.BeginDrawing();
        {
            if (enable_shaders) {
                rl.BeginShaderMode(shader);
                {
                    u_time += rl.GetFrameTime();
                    const u_time_loc = rl.GetShaderLocation(shader, "u_time");
                    rl.SetShaderValue(shader, u_time_loc, &u_time, rl.SHADER_UNIFORM_FLOAT);
                    // flip the coordinates as openGL defaults (left-bottom)
                    rl.DrawTextureRec(target.texture, .{ .x = 0, .y = 0, .width = @as(f32, @floatFromInt(target.texture.width)), .height = @as(f32, @floatFromInt(-target.texture.height)) }, .{ .x = 0, .y = 0 }, rl.WHITE);
                }
                rl.EndShaderMode();
            } else {
                rl.DrawTextureRec(target.texture, .{ .x = 0, .y = 0, .width = @as(f32, @floatFromInt(target.texture.width)), .height = @as(f32, @floatFromInt(-target.texture.height)) }, .{ .x = 0, .y = 0 }, rl.WHITE);
            }
        }
        rl.EndDrawing();
    }

    // clean up
    rl.CloseWindow();
    rl.UnloadRenderTexture(target);
    rl.UnloadShader(shader);
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
