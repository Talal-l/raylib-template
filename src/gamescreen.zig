const std = @import("std");
const rl = @cImport({
    @cInclude("raylib.h");
    @cInclude("raymath.h");
});
const utils = @import("utils.zig");

const Player = struct {
    rect: rl.Rectangle,
    color: rl.Color,
};

const Ball = struct {
    center: rl.Vector2,
    radius: f32,
    velocity: rl.Vector2,
    color: rl.Color,
    fn bounceHorizontal(self: *Ball) void {
        self.velocity.x = -self.velocity.x;
    }
    fn bounceVertical(self: *Ball) void {
        self.velocity.y = -self.velocity.y;
    }
};

var p1: Player = undefined;
var p2: Player = undefined;
var ball: Ball = undefined;

pub fn init() void {
    p1 = .{
        .rect = .{
            .x = 20,
            .y = utils.getScreenHeight() / 2.0,
            .width = 20,
            .height = 20,
        },
        .color = rl.RAYWHITE,
    };

    p2 = .{
        .rect = .{
            .x = utils.getScreenWidth() - 30,
            .y = utils.getScreenHeight() / 2.0,
            .width = 20,
            .height = 20,
        },
        .color = rl.RAYWHITE,
    };

    ball = .{
        .center = .{
            .x = utils.getScreenWidth() / 2,
            .y = utils.getScreenHeight() / 2,
        },
        .radius = 10.0,
        .velocity = .{
            .x = @as(f32, @floatFromInt(rl.GetRandomValue(0, 1000))) / 900.0 + 1,
            .y = @as(f32, @floatFromInt(rl.GetRandomValue(0, 1000))) / 900.0 + 1,
        },
        .color = rl.RED,
    };

    std.debug.print("player1: {any}", .{p1});
}

pub fn update() void {
    if (rl.IsKeyDown(rl.KEY_W)) {
        p1.rect.y -= 10;
    }

    if (rl.IsKeyDown(rl.KEY_S)) {
        p1.rect.y += 10;
    }

    p1.rect.y = rl.Clamp(p1.rect.y, 0, utils.getScreenHeight() - p1.rect.height);

    if (rl.IsKeyDown(rl.KEY_UP)) {
        p2.rect.y -= 10;
    }

    if (rl.IsKeyDown(rl.KEY_DOWN)) {
        p2.rect.y += 10;
    }

    p2.rect.y = rl.Clamp(p2.rect.y, 0, utils.getScreenHeight() - p2.rect.height);

    ball.center = rl.Vector2Add(ball.center, ball.velocity);

    // touch players
    if (rl.CheckCollisionCircleRec(ball.center, ball.radius, p1.rect) or
        rl.CheckCollisionCircleRec(ball.center, ball.radius, p2.rect))
    {
        ball.bounceHorizontal();
        ball.velocity.x *= 1.5;
    }

    // touch top and bottom walls
    if (rl.CheckCollisionCircleLine(ball.center, ball.radius, rl.Vector2{ .x = 0, .y = 0 }, rl.Vector2{ .x = utils.getScreenWidth(), .y = 0 }) or
        rl.CheckCollisionCircleLine(ball.center, ball.radius, rl.Vector2{ .x = 0, .y = utils.getScreenHeight() }, rl.Vector2{ .x = utils.getScreenWidth(), .y = utils.getScreenHeight() }))
    {
        ball.bounceVertical();
    }
}

pub fn draw() void {
    rl.ClearBackground(rl.BLACK);

    rl.DrawRectangleRec(p1.rect, p1.color);
    rl.DrawRectangleRec(p2.rect, p2.color);
    rl.DrawCircleV(ball.center, ball.radius, ball.color);
}
