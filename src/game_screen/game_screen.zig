const std = @import("std");
const utils = @import("../utils.zig");
const rl = @import("../rl.zig");

// importing types
const GameState = @import("../game.zig").GameState;
const Player = @import("player.zig").Player;
const Ball = @import("ball.zig").Ball;

pub const GameScreenState = struct {
    p1: Player,
    p2: Player,
    ball: Ball,
    score1: i32,
    score2: i32,
    score1String: [10]u8,
    score2String: [10]u8,
    pub fn init() GameScreenState {
        return .{
            .p1 = Player.init(.Player1),
            .p2 = Player.init(.Player2),
            .ball = Ball.init(),
            .score1 = 0,
            .score2 = 0,
            .score1String = [_]u8{0} ** 10,
            .score2String = [_]u8{0} ** 10,
        };
    }

    // todo: change game_state_ptr to game_screen_state pointer
    pub fn update(state: *GameScreenState) void {
        // reset ball on space bar
        if (rl.IsKeyDown(rl.KEY_SPACE)) {
            state.ball.reset();
        }

        // player 1 move logic
        if (rl.IsKeyDown(rl.KEY_W)) state.p1.moveUp();
        if (rl.IsKeyDown(rl.KEY_S)) state.p1.moveDown();
        state.p1.clampPosY();

        // player 2 move logic
        if (rl.IsKeyDown(rl.KEY_UP)) state.p2.moveUp();
        if (rl.IsKeyDown(rl.KEY_DOWN)) state.p2.moveDown();
        state.p2.clampPosY();

        // move ball based on its velocity
        state.ball.center = rl.Vector2Add(state.ball.center, state.ball.velocity);

        // ball touch player 1
        if (rl.CheckCollisionCircleRec(state.ball.center, state.ball.radius, state.p1.rect)) {
            state.ball.bounceHorizontal();
            state.ball.velocity = rl.Vector2Scale(state.ball.velocity, 1.5);
        }

        // ball touch player 2
        if (rl.CheckCollisionCircleRec(state.ball.center, state.ball.radius, state.p2.rect)) {
            state.ball.bounceHorizontal();
            state.ball.velocity = rl.Vector2Scale(state.ball.velocity, 1.5);
        }

        // ball touch top and bottom walls
        if (rl.CheckCollisionCircleLine(state.ball.center, state.ball.radius, rl.Vector2{ .x = 0, .y = 0 }, rl.Vector2{ .x = utils.getScreenWidth(), .y = 0 }) or
            rl.CheckCollisionCircleLine(state.ball.center, state.ball.radius, rl.Vector2{ .x = 0, .y = utils.getScreenHeight() }, rl.Vector2{ .x = utils.getScreenWidth(), .y = utils.getScreenHeight() }))
        {
            state.ball.bounceVertical();
        }

        // ball touch left wall
        if (rl.CheckCollisionCircleLine(state.ball.center, state.ball.radius, utils.topLeftCorner(), utils.bottomLeftCorner())) {
            state.score2 += 1;
            state.ball.reset();
        }

        // touch right wall
        if (rl.CheckCollisionCircleLine(state.ball.center, state.ball.radius, utils.topRightCorner(), utils.bottomRightCorner())) {
            state.score1 += 1;
            state.ball.reset();
        }
    }

    pub fn draw(state: *GameScreenState) void {
        rl.ClearBackground(rl.BLACK);

        rl.DrawRectangleRec(state.p1.rect, state.p1.color);
        rl.DrawRectangleRec(state.p2.rect, state.p2.color);

        rl.DrawCircleV(state.ball.center, state.ball.radius, state.ball.color);

        _ = std.fmt.formatIntBuf(&state.score1String, state.score1, 10, .lower, .{});
        _ = std.fmt.formatIntBuf(&state.score2String, state.score2, 10, .lower, .{});

        const score1PosX = -20 + @as(c_int, @divTrunc(@as(i32, @intFromFloat(utils.getScreenWidth())), 2));
        rl.DrawText(&state.score1String, score1PosX, 10, 40, rl.WHITE);

        const score2PosX = 20 + @as(c_int, @divTrunc(@as(i32, @intFromFloat(utils.getScreenWidth())), 2));
        rl.DrawText(&state.score2String, score2PosX, 10, 40, rl.WHITE);
    }
};
