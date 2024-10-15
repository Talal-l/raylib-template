const std = @import("std");
const rl = @import("../rl.zig");

const MenuScreenState = struct {
    current_option_index: u8,

    pub fn init() MenuScreenState {
        return .{
            .current_option_index = 0,
        };
    }

    pub fn update(self: *MenuScreenState) void {
        _ = self;
    }

    pub fn draw(self: *MenuScreenState) void {
        rl.ClearBackground(rl.RAYWHITE);
        rl.DrawText("Menu Screen", @divTrunc(rl.GetScreenWidth(), 2), @divTrunc(rl.GetScreenHeight(), 2), 70, rl.BLACK);
        _ = self;
    }
};
