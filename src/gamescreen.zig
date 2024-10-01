const std = @import("std");
const utils = @import("utils.zig");
const rl = @import("rl.zig");
const GameState = @import("game.zig").GameState;

pub fn init() void {}

pub fn update(game_state_ptr: *anyopaque) void {
    var game_state: GameState = @ptrCast(@alignCast(game_state_ptr));
    // reset ball on space bar
    if (rl.IsKeyDown(rl.KEY_SPACE)) {
        game_state.ball.reset();
    }

    // player 1 move logic
    if (rl.IsKeyDown(rl.KEY_W)) game_state.p1.rect.y -= 10;
    if (rl.IsKeyDown(rl.KEY_S)) game_state.p1.rect.y += 10;
    game_state.p1.rect.y = rl.Clamp(game_state.p1.rect.y, 0, utils.getScreenHeight() - game_state.p1.rect.height);

    // player 2 move logic
    if (rl.IsKeyDown(rl.KEY_UP)) game_state.p2.rect.y -= 10;
    if (rl.IsKeyDown(rl.KEY_DOWN)) game_state.p2.rect.y += 10;
    game_state.p2.rect.y = rl.Clamp(game_state.p2.rect.y, 0, utils.getScreenHeight() - game_state.p2.rect.height);

    game_state.ball.center = rl.Vector2Add(game_state.ball.center, game_state.ball.velocity);

    // touch player 1
    if (rl.CheckCollisionCircleRec(game_state.ball.center, game_state.ball.radius, game_state.p1.rect)) {
        game_state.ball.bounceHorizontal();
        game_state.ball.velocity = rl.Vector2Scale(game_state.ball.velocity, 1.5);
    }

    // touch player 2
    if (rl.CheckCollisionCircleRec(game_state.ball.center, game_state.ball.radius, game_state.p2.rect)) {
        game_state.ball.bounceHorizontal();
        game_state.ball.velocity = rl.Vector2Scale(game_state.ball.velocity, 1.5);
    }

    // touch top and bottom walls
    if (rl.CheckCollisionCircleLine(game_state.ball.center, game_state.ball.radius, rl.Vector2{ .x = 0, .y = 0 }, rl.Vector2{ .x = utils.getScreenWidth(), .y = 0 }) or
        rl.CheckCollisionCircleLine(game_state.ball.center, game_state.ball.radius, rl.Vector2{ .x = 0, .y = utils.getScreenHeight() }, rl.Vector2{ .x = utils.getScreenWidth(), .y = utils.getScreenHeight() }))
    {
        game_state.ball.bounceVertical();
    }

    // touch left wall
    if (rl.CheckCollisionCircleLine(game_state.ball.center, game_state.ball.radius, utils.topLeftCorner(), utils.bottomLeftCorner())) {
        game_state.score2 += 1;
        game_state.ball.reset();
    }

    // touch right wall
    if (rl.CheckCollisionCircleLine(game_state.ball.center, game_state.ball.radius, utils.topRightCorner(), utils.bottomRightCorner())) {
        game_state.score1 += 1;
        game_state.ball.reset();
    }
}

pub fn draw(game_state_ptr: *anyopaque) void {
    var game_state: GameState = @ptrCast(@alignCast(game_state_ptr));
    rl.ClearBackground(rl.BLACK);

    rl.DrawRectangleRec(game_state.p1.rect, game_state.p1.color);
    rl.DrawRectangleRec(game_state.p2.rect, game_state.p2.color);
    rl.DrawCircleV(game_state.ball.center, game_state.ball.radius, game_state.ball.color);

    _ = std.fmt.formatIntBuf(&game_state.score1String, game_state.score1, 10, .lower, .{});
    _ = std.fmt.formatIntBuf(&game_state.score2String, game_state.score2, 10, .lower, .{});

    const score1PosX = -20 + @as(c_int, @divTrunc(@as(i32, @intFromFloat(utils.getScreenWidth())), 2));
    rl.DrawText(&game_state.score1String, score1PosX, 10, 40, rl.WHITE);

    const score2PosX = 20 + @as(c_int, @divTrunc(@as(i32, @intFromFloat(utils.getScreenWidth())), 2));
    rl.DrawText(&game_state.score2String, score2PosX, 10, 40, rl.WHITE);
}
