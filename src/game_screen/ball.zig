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
    pub fn bounceHorizontal(self: *Ball) void {
        self.velocity.x = -self.velocity.x;
    }
    pub fn bounceVertical(self: *Ball) void {
        self.velocity.y = -self.velocity.y;
    }
    pub fn reset(self: *Ball) void {
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
