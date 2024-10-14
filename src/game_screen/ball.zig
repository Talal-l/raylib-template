const rl = @import("../rl.zig");
const utils = @import("../utils.zig");

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
    pub fn flipVelocityHorizontal(self: *Ball) void {
        self.velocity.x = -self.velocity.x;
    }
    pub fn flipVelocityVertical(self: *Ball) void {
        self.velocity.y = -self.velocity.y;
    }
    pub fn scaleVelocity(self: *Ball, scale: f32) void {
        self.velocity = rl.Vector2Scale(self.velocity, scale);
    }

    /// move ball based on its velocity
    ///
    /// ball touch top or bottom walls
    pub fn update(self: *Ball) void {
        self.center = rl.Vector2Add(self.center, self.velocity);
        if (rl.CheckCollisionCircleLine(self.center, self.radius, rl.Vector2{ .x = 0, .y = 0 }, rl.Vector2{ .x = utils.getScreenWidth(), .y = 0 }) or
            rl.CheckCollisionCircleLine(self.center, self.radius, rl.Vector2{ .x = 0, .y = utils.getScreenHeight() }, rl.Vector2{ .x = utils.getScreenWidth(), .y = utils.getScreenHeight() }))
        {
            self.flipVelocityVertical();
        }
    }
    /// draw ball circle
    pub fn draw(self: *Ball) void {
        rl.DrawCircleV(self.center, self.radius, self.color);
    }
    /// reset the balls position and velocity
    pub fn reset(self: *Ball) void {
        self.center = .{
            .x = utils.getScreenWidth() / 2,
            .y = utils.getScreenHeight() / 2,
        };

        self.velocity = .{
            .x = @as(f32, @floatFromInt(rl.GetRandomValue(-3000, 3000))) / 1000.0,
            .y = @as(f32, @floatFromInt(rl.GetRandomValue(-2500, 2500))) / 1000.0,
        };
        self.velocity = rl.Vector2Normalize(self.velocity);
        self.scaleVelocity(5);
    }
};
