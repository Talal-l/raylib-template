const std = @import("std");
const utils = @import("utils.zig");
const rl = @import("rl.zig");
const GameState = @import("game.zig").GameState;

pub const Player = struct {
    const width: f32 = 20;
    const height: f32 = 40;

    rect: rl.Rectangle,
    color: rl.Color,

    pub fn init(player_type: PlayerType) Player {
        return .{
            .rect = .{
                .x = if (player_type == .Player1) 20.0 else utils.getScreenWidth() - Player.width - 20,
                .y = utils.getScreenHeight() / 2.0,
                .width = Player.width,
                .height = Player.height,
            },
            .color = rl.RAYWHITE,
        };
    }
    pub const PlayerType = enum { Player1, Player2 };
};

pub const Ball = struct {
    center: rl.Vector2,
    radius: f32,
    velocity: rl.Vector2,
    color: rl.Color,
    pub fn init() Ball {
        var b: Ball = .{
            .center = .{},
            .radius = 10.0,
            .velocity = .{},
            .color = rl.RED,
        };
        b.reset();
        return b;
    }
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
