const rl = @cImport({
    @cInclude("raylib.h");
});

pub fn getScreenWidth() f32 {
    return @floatFromInt(rl.GetScreenWidth());
}

pub fn getScreenHeight() f32 {
    return @floatFromInt(rl.GetScreenHeight());
}
