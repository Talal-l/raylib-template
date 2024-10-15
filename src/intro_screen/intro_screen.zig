// importing libraries
const std = @import("std");
const rl = @import("../rl.zig");

pub const IntroScreenState = struct {
    start_timer: i64,
    done: bool,
    pub fn init() IntroScreenState {
        return .{
            .start_timer = std.time.timestamp(),
            .done = false,
        };
    }

    /// Check if enough time has elapsed to change 'done' flag to true
    pub fn update(self: *IntroScreenState) void {
        if (std.time.timestamp() - self.start_timer < 5) {
            return;
        }

        self.done = true;
    }

    /// draw the intro screen
    pub fn draw(self: *IntroScreenState) void {
        _ = self;
        rl.ClearBackground(rl.RAYWHITE);
        const text_size = rl.MeasureTextEx(rl.GetFontDefault(), "Zing", 70, 1);
        const text_pos_x: c_int = @divTrunc(rl.GetScreenWidth(), 2) - @as(c_int, @intFromFloat(text_size.x / 2));
        const text_pos_y: c_int = @divTrunc(rl.GetScreenHeight(), 2) - @as(c_int, @intFromFloat(text_size.y / 2));

        rl.DrawText("Zing", text_pos_x, text_pos_y, 70, rl.BLACK);
    }
};
