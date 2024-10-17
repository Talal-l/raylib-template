// IMPORTING LIBRARIES
const std = @import("std");
const utils = @import("../utils.zig");
const rl = @import("../rl.zig");

// IMPORTING TYPES
const Player = @import("player.zig").Player;
const Ball = @import("ball.zig").Ball;

// CONSTS
const BOUNCE_SCALE_AMOUNT = 1.2;
const NEW_ROUND_TIMER_LENGTH = 3;
const BALL_BOUND_SFX_PATH = "assets/sfx/ball_bounce.wav";

// STATE
pub const GameScreenState = struct {
    p1: Player,
    p2: Player,
    ball: Ball,
    score1: i32,
    score2: i32,
    score1String: [10]u8,
    score2String: [10]u8,
    start_timer: i64,
    ball_bounce_sfx: rl.Sound,

    pub fn init() GameScreenState {
        return .{
            .p1 = Player.init(.Player1),
            .p2 = Player.init(.Player2),
            .ball = Ball.init(),
            .score1 = 0,
            .score2 = 0,
            .score1String = [_]u8{0} ** 10,
            .score2String = [_]u8{0} ** 10,
            .start_timer = 0,
            .ball_bounce_sfx = rl.LoadSound(BALL_BOUND_SFX_PATH),
        };
    }

    pub fn update(self: *GameScreenState) void {
        // reset ball on space bar
        if (rl.IsKeyDown(rl.KEY_SPACE)) {
            self.ball.reset();
        }

        self.p1.update();
        self.p2.update();

        if (std.time.timestamp() - self.start_timer <= 3) {
            return;
        }

        self.ball.update();

        // TODO: add some physics with the bounce so that the angle the balls flies off on is relative to the face on the ball
        //  make sure to clamp the shit out of it so you dont have to wait 1 million years because the player hit the skibbity corner
        // ball touch player 1
        if (rl.CheckCollisionCircleRec(self.ball.center, self.ball.radius, self.p1.rect)) {
            self.ball.flipVelocityHorizontal();
            self.ball.scaleVelocity(BOUNCE_SCALE_AMOUNT);
            self.ball.center = .{ .x = self.p1.rect.x + self.p1.rect.width + self.ball.radius, .y = self.ball.center.y };
            rl.PlaySound(self.ball_bounce_sfx);
        }

        // ball touch player 2
        if (rl.CheckCollisionCircleRec(self.ball.center, self.ball.radius, self.p2.rect)) {
            self.ball.flipVelocityHorizontal();
            self.ball.scaleVelocity(BOUNCE_SCALE_AMOUNT);
            self.ball.center = .{ .x = self.p2.rect.x - self.ball.radius, .y = self.ball.center.y };
            rl.PlaySound(self.ball_bounce_sfx);
        }

        // ball can go behind the 'front' of player 1, with some leeway
        if (self.ball.center.x - self.ball.radius <= self.p1.rect.x + self.p1.rect.width / 2) {
            self.score2 += 1;
            self.ball.reset();
            self.start_timer = std.time.timestamp();
        }

        // same as above but reversed for player 2
        if (self.ball.center.x + self.ball.radius >= self.p2.rect.x + self.p2.rect.width / 2) {
            self.score1 += 1;
            self.ball.reset();
            self.start_timer = std.time.timestamp();
        }
    }

    pub fn draw(self: *GameScreenState) void {
        rl.ClearBackground(rl.BLACK);

        // Draw the scores
        _ = std.fmt.formatIntBuf(&self.score1String, self.score1, 10, .lower, .{});
        _ = std.fmt.formatIntBuf(&self.score2String, self.score2, 10, .lower, .{});
        rl.DrawText(&self.score1String, @divTrunc(rl.GetScreenWidth(), 2) - 20, 10, 40, rl.WHITE);
        rl.DrawText(&self.score2String, 20 + @divTrunc(rl.GetScreenWidth(), 2), 10, 40, rl.WHITE);

        // Draw players
        self.p1.draw();
        self.p2.draw();

        // Draw Ball
        self.ball.draw();

        const time_since_start_timer = std.time.timestamp() - self.start_timer;
        if (time_since_start_timer <= 3) {
            var out_buf: [10]u8 = [_]u8{0} ** 10;
            const timer_font_size = 60;
            _ = std.fmt.formatIntBuf(&out_buf, 3 - time_since_start_timer, 10, .lower, .{});
            const text_size = rl.MeasureTextEx(rl.GetFontDefault(), &out_buf, timer_font_size, 1);

            const pos_x: c_int = @divTrunc(rl.GetScreenWidth(), 2) - @as(c_int, @intFromFloat(text_size.x / 2.0));
            const pos_y: c_int = @divTrunc(rl.GetScreenHeight(), 2) - @as(c_int, @intFromFloat(text_size.y / 2.0));
            rl.DrawText(&out_buf, pos_x, pos_y, timer_font_size, rl.WHITE);
        }
    }
};
