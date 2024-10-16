// importing libraries
const std = @import("std");
const rl = @import("../rl.zig");
const utils = @import("../utils.zig");

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
        const text_size = rl.MeasureTextEx(rl.GetFontDefault(), "Zing", 70, 1);
        const text_pos_x: c_int = @divTrunc(rl.GetScreenWidth(), 2) - @as(c_int, @intFromFloat(text_size.x / 2));
        const text_pos_y: c_int = @divTrunc(rl.GetScreenHeight(), 2) - @as(c_int, @intFromFloat(text_size.y / 2));

        rl.ClearBackground(rl.RAYWHITE);
        rl.DrawText("Zing", text_pos_x, text_pos_y, 70, rl.BLACK);

        // Black screen ontop to give fade in/out effect
        var time_f: f32 = @floatFromInt(std.time.milliTimestamp() - self.start_timer * 1000);
        time_f /= 1000;

        const fade_alpha: u8 = @intFromFloat(rl.Remap(
            @floatCast(rl.sin(
                rl.Remap(time_f, 0.0, 5.0, 0.0, rl.PI),
            )),
            0,
            1,
            255,
            0,
        ));

        rl.DrawRectangleRec(
            .{ .x = 0, .y = 0, .width = utils.getScreenWidth(), .height = utils.getScreenHeight() },
            .{ .r = 0, .g = 0, .b = 0, .a = fade_alpha },
        );
    }
};
