const std = @import("std");
const rl = @import("../rl.zig");
const utils = @import("../utils.zig");

var menu_text_size: c_int = undefined;
const option_texts = [_][*c]const u8{ "START", "EXIT" };
const menu_screen_title = "Menu Screen";
const menu_screen_title_font_size = 60;

pub const MenuScreenState = struct {
    current_option_index: i32,
    done: bool,

    pub fn init() MenuScreenState {
        menu_text_size = rl.MeasureText(menu_screen_title, menu_screen_title_font_size);

        return .{
            .done = false,
            .current_option_index = 0,
        };
    }

    pub fn update(self: *MenuScreenState) void {
        if (rl.IsKeyPressed(rl.KEY_ENTER)) {
            if (self.current_option_index == 0) {
                self.done = true;
            } else if (self.current_option_index == 1) {
                // TODO: change this so that it exits properly
                rl.CloseWindow();
            }
        }

        if (rl.IsKeyPressed(rl.KEY_UP))
            self.current_option_index -= 1;

        if (rl.IsKeyPressed(rl.KEY_DOWN))
            self.current_option_index += 1;

        if (self.current_option_index < 0)
            self.current_option_index = 0;

        if (self.current_option_index >= option_texts.len)
            self.current_option_index = option_texts.len - 1;
    }

    pub fn draw(self: *MenuScreenState) void {
        rl.ClearBackground(rl.BLACK);
        rl.DrawText(
            menu_screen_title,
            @as(c_int, @intFromFloat(utils.getHalfScreenWidth())) - @divTrunc(menu_text_size, 2),
            0,
            menu_screen_title_font_size,
            rl.WHITE,
        );

        for (0.., option_texts) |i, option_text| {
            const option_text_size = rl.MeasureTextEx(
                rl.GetFontDefault(),
                option_text,
                40,
                1,
            );
            const option_text_pos_x: c_int = @intFromFloat(utils.getHalfScreenWidth() - option_text_size.x / 2);
            const option_text_pos_y: c_int = @intFromFloat(utils.getHalfScreenHeight() + @as(f32, @floatFromInt(i)) * option_text_size.y);

            rl.DrawText(
                option_text,
                option_text_pos_x,
                option_text_pos_y,
                40,
                rl.WHITE,
            );

            if (self.current_option_index == i) {
                rl.DrawRectangleRec(
                    .{
                        .x = @floatFromInt(option_text_pos_x),
                        .y = @floatFromInt(option_text_pos_y),
                        .width = option_text_size.x,
                        .height = option_text_size.y + 5,
                    },
                    .{ .r = 255, .g = 255, .b = 255, .a = 100 },
                );
            }
        }
    }
};
