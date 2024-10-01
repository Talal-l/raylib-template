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
    fn reset(self: *Ball) void {
        self.center = .{
            .x = utils.getScreenWidth() / 2,
            .y = utils.getScreenHeight() / 2,
        };

        self.velocity = .{
            .x = @as(f32, @floatFromInt(rl.GetRandomValue(-3000, 3000))) / 1000.0,
            .y = @as(f32, @floatFromInt(rl.GetRandomValue(-3000, 3000))) / 1000.0,
        };
    }
};

var p1: Player = undefined;
var p2: Player = undefined;
var ball: Ball = undefined;
var score1: i32 = 0;
var score2: i32 = 0;
var score1String = [_]u8{0} ** 10;
var score2String = [_]u8{0} ** 10;

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
        .center = .{},
        .radius = 10.0,
        .velocity = .{},
        .color = rl.RED,
    };
    ball.reset();

    std.debug.print("player1: {any}", .{p1});
}

pub fn update() void {
    // reset ball on space bar
    if (rl.IsKeyDown(rl.KEY_SPACE)) {
        ball.reset();
    }

    // player 1 move logic
    if (rl.IsKeyDown(rl.KEY_W)) p1.rect.y -= 10;
    if (rl.IsKeyDown(rl.KEY_S)) p1.rect.y += 10;
    p1.rect.y = rl.Clamp(p1.rect.y, 0, utils.getScreenHeight() - p1.rect.height);

    // player 2 move logic
    if (rl.IsKeyDown(rl.KEY_UP)) p2.rect.y -= 10;
    if (rl.IsKeyDown(rl.KEY_DOWN)) p2.rect.y += 10;
    p2.rect.y = rl.Clamp(p2.rect.y, 0, utils.getScreenHeight() - p2.rect.height);

    ball.center = rl.Vector2Add(ball.center, ball.velocity);

    // touch player 1
    if (rl.CheckCollisionCircleRec(ball.center, ball.radius, p1.rect)) {
        ball.bounceHorizontal();
        ball.velocity = rl.Vector2Scale(ball.velocity, 1.5);
    }

    // touch player 2
    if (rl.CheckCollisionCircleRec(ball.center, ball.radius, p2.rect)) {
        ball.bounceHorizontal();
        ball.velocity = rl.Vector2Scale(ball.velocity, 1.5);
    }

    // touch top and bottom walls
    if (rl.CheckCollisionCircleLine(ball.center, ball.radius, rl.Vector2{ .x = 0, .y = 0 }, rl.Vector2{ .x = utils.getScreenWidth(), .y = 0 }) or
        rl.CheckCollisionCircleLine(ball.center, ball.radius, rl.Vector2{ .x = 0, .y = utils.getScreenHeight() }, rl.Vector2{ .x = utils.getScreenWidth(), .y = utils.getScreenHeight() }))
    {
        ball.bounceVertical();
    }

    // touch left wall
    if (rl.CheckCollisionCircleLine(ball.center, ball.radius, rl.Vector2{ .x = 0, .y = 0 }, rl.Vector2{ .x = 0, .y = utils.getScreenHeight() })) {
        score2 += 1;
        ball.reset();
    }

    // touch right wall
    if (rl.CheckCollisionCircleLine(ball.center, ball.radius, rl.Vector2{ .x = utils.getScreenWidth(), .y = 0 }, rl.Vector2{ .x = utils.getScreenWidth(), .y = utils.getScreenHeight() })) {
        score1 += 1;
        ball.reset();
    }
}

pub fn draw() void {
    rl.ClearBackground(rl.BLACK);

    rl.DrawRectangleRec(p1.rect, p1.color);
    rl.DrawRectangleRec(p2.rect, p2.color);
    rl.DrawCircleV(ball.center, ball.radius, ball.color);

    _ = std.fmt.formatIntBuf(&score1String, score1, 10, .lower, .{});
    _ = std.fmt.formatIntBuf(&score2String, score2, 10, .lower, .{});

    const score1PosX = -20 + @as(c_int, @divTrunc(@as(i32, @intFromFloat(utils.getScreenWidth())), 2));
    rl.DrawText(&score1String, score1PosX, 10, 40, rl.WHITE);

    const score2PosX = 20 + @as(c_int, @divTrunc(@as(i32, @intFromFloat(utils.getScreenWidth())), 2));
    rl.DrawText(&score2String, score2PosX, 10, 40, rl.WHITE);
}
