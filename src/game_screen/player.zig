const rl = @import("../rl.zig");
const utils = @import("../utils.zig");

pub const Player = struct {
    const width: f32 = 20;
    const height: f32 = 40;

    rect: rl.Rectangle,
    color: rl.Color,

    pub fn init(player_type: PlayerType) Player {
        return .{
            .rect = .{
                .x = if (player_type == .Player1) 20.0 else (utils.getScreenWidth() - Player.width - 20),
                .y = utils.getScreenHeight() / 2.0,
                .width = Player.width,
                .height = Player.height,
            },
            .color = if (player_type == .Player1) rl.BEIGE else rl.DARKBROWN,
        };
    }
    pub fn moveDown(self: *Player) void {
        self.rect.y += 10;
    }
    pub fn moveUp(self: *Player) void {
        self.rect.y -= 10;
    }
    pub fn clampPosY(self: *Player) void {
        self.rect.y = rl.Clamp(self.rect.y, 0, utils.getScreenHeight() - self.rect.height);
    }

    pub const PlayerType = enum { Player1, Player2 };
};
