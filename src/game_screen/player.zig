const rl = @import("../rl.zig");
const utils = @import("../utils.zig");

pub const Player = struct {
    const width: f32 = 20;
    const height: f32 = 40;

    rect: rl.Rectangle,
    color: rl.Color,
    move_up_key: i32,
    move_down_key: i32,

    pub fn init(player_type: PlayerType) Player {
        return .{
            .rect = .{
                .x = if (player_type == .Player1) 20.0 else (utils.getScreenWidth() - Player.width - 20),
                .y = utils.getScreenHeight() / 2.0,
                .width = Player.width,
                .height = Player.height,
            },
            .color = if (player_type == .Player1) rl.BEIGE else rl.DARKBROWN,
            .move_up_key = if (player_type == .Player1) rl.KEY_W else rl.KEY_UP,
            .move_down_key = if (player_type == .Player1) rl.KEY_S else rl.KEY_DOWN,
        };
    }
    // TODO: add velocity and acceleration 0^0 ehheheeheh
    pub fn moveDown(self: *Player) void {
        self.rect.y += 10;
    }
    pub fn moveUp(self: *Player) void {
        self.rect.y -= 10;
    }
    /// move on key press
    pub fn update(self: *Player) void {
        if (rl.IsKeyDown(self.move_up_key)) self.moveUp();
        if (rl.IsKeyDown(self.move_down_key)) self.moveDown();
        self.clampPosY();
    }
    /// draw the player rectangle
    pub fn draw(self: *Player) void {
        rl.DrawRectangleRec(self.rect, self.color);
    }
    /// clamp the y so player doesnt move out of the screen
    pub fn clampPosY(self: *Player) void {
        self.rect.y = rl.Clamp(self.rect.y, 0, utils.getScreenHeight() - self.rect.height);
    }

    pub const PlayerType = enum { Player1, Player2 };
};
