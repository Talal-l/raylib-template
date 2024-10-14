const rl = @import("rl.zig");
pub const EnvVars = struct {
    quit_key: u8,
    hot_reload_key: u8,
    dark_mode: bool,
};

pub var env_vars = EnvVars{
    .quit_key = 'Q',
    .hot_reload_key = 'R',
    .dark_mode = false,
};

pub fn getScreenWidth() f32 {
    return @floatFromInt(rl.GetScreenWidth());
}

pub fn getScreenHeight() f32 {
    return @floatFromInt(rl.GetScreenHeight());
}

pub fn topLeftCorner() rl.Vector2 {
    return rl.Vector2{ .x = 0, .y = 0 };
}

pub fn topRightCorner() rl.Vector2 {
    return rl.Vector2{ .x = getScreenWidth(), .y = 0 };
}

pub fn bottomLeftCorner() rl.Vector2 {
    return rl.Vector2{ .x = 0, .y = getScreenHeight() };
}

pub fn bottomRightCorner() rl.Vector2 {
    return rl.Vector2{ .x = getScreenWidth(), .y = getScreenHeight() };
}
