const std = @import("std");
const rl = @cImport({
    @cInclude("raylib.h");
});

pub fn main() !void {
    std.debug.print("Hello world", .{});
    rl.InitWindow(400, 400, "TEMPLATE");
    rl.SetTargetFPS(60);

    while (!rl.WindowShouldClose()) {
        rl.BeginDrawing();

        rl.EndDrawing();
    }

    rl.CloseWindow();
}
