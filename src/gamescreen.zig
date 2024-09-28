const std = @import("std");
const rl = @cImport({
    @cInclude("raylib.h");
    @cInclude("raymath.h");
});
const utils = @import("utils.zig");

const Player = struct {
    pos: rl.Vector2,
    color: rl.Color,
};

const playerSize: rl.Vector2 = .{ .x = 20, .y = 30 };
var p1: Player = undefined;
var p2: Player = undefined;

pub fn init() void {
    p1 = .{
        .pos = .{
            .x = playerSize.x / 2 + 10,
            .y = utils.getScreenHeight() / 2.0,
        },
        .color = rl.RAYWHITE,
    };

    p2 = .{
        .pos = .{
            .x = utils.getScreenWidth() - (playerSize.x / 2 + 10) * 2,
            .y = utils.getScreenHeight() / 2.0,
        },
        .color = rl.RAYWHITE,
    };

    std.debug.print("player1: {any}", .{p1});
}

pub fn update() void {
    if (rl.IsKeyDown(rl.KEY_W)) {
        p1.pos.y -= 10;
    }

    if (rl.IsKeyDown(rl.KEY_S)) {
        p1.pos.y += 10;
    }

    p1.pos.y = rl.Clamp(p1.pos.y, 0, utils.getScreenHeight() - playerSize.y);

    if (rl.IsKeyDown(rl.KEY_UP)) {
        p2.pos.y -= 10;
    }

    if (rl.IsKeyDown(rl.KEY_DOWN)) {
        p2.pos.y += 10;
    }

    p2.pos.y = rl.Clamp(p2.pos.y, 0, utils.getScreenHeight() - playerSize.y);
}

pub fn draw() void {
    rl.ClearBackground(rl.BLACK);
    rl.DrawRectangleV(p1.pos, playerSize, p1.color);
    rl.DrawRectangleV(p2.pos, playerSize, p2.color);
}
