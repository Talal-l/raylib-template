const std = @import("std");
const rl = @cImport({
    @cInclude("raylib.h");
});
const gameScreen = @import("gamescreen.zig");

const screen_w = 500;
const screen_h = 500;

pub fn main() !void {
    rl.InitWindow(screen_w, screen_h, "Pong");
    rl.SetTargetFPS(60);
    rl.SetWindowMonitor(1);
    gameScreen.init();
    while (!rl.WindowShouldClose()) {
        if (rl.IsKeyPressed(rl.KEY_X) or rl.IsKeyPressed(rl.KEY_Q)) {
            rl.CloseWindow();
            return;
        }
        gameScreen.update();
        rl.BeginDrawing();
        gameScreen.draw();
        rl.EndDrawing();
    }
    rl.CloseWindow();
}
