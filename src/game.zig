const std = @import("std");
const rl = @import("rl.zig");
const utils = @import("utils.zig");
const game_screen = @import("gamescreen.zig");

const Player = struct {
    const width: f32 = 20;
    const height: f32 = 40;

    rect: rl.Rectangle,
    color: rl.Color,

    fn init(posX: f32) Player {
        return .{
            .rect = .{
                .x = posX,
                .y = utils.getScreenHeight() / 2.0,
                .width = Player.width,
                .height = Player.height,
            },
            .color = rl.RAYWHITE,
        };
    }
};

const Ball = struct {
    center: rl.Vector2,
    radius: f32,
    velocity: rl.Vector2,
    color: rl.Color,
    fn init() Ball {
        var b: Ball = .{
            .center = .{},
            .radius = 10.0,
            .velocity = .{},
            .color = rl.RED,
        };
        b.reset();
        return b;
    }
    fn bounceHorizontal(self: *Ball) void {
        self.velocity.x = -self.velocity.x;
    }
    fn bounceVertical(self: *Ball) void {
        self.velocity.y = -self.velocity.y;
    }
    fn reset(self: *Ball) void {
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
pub const GameState = struct {
    allocator: std.mem.Allocator,
    p1: Player,
    p2: Player,
    ball: Ball,
    score1: i32 = 0,
    score2: i32 = 0,
    score1String: [10]u8 = [_]u8{0} ** 10,
    score2String: [10]u8 = [_]u8{0} ** 10,
};

export fn gameInit() *anyopaque {
    var allocator = std.heap.page_allocator;
    const game_state = allocator.create(GameState) catch @panic("Out of memory");

    game_state.* = GameState{
        .allocator = allocator,
        .p1 = Player.init(20),
        .p2 = Player.init(utils.getScreenWidth() - Player.width - 20),
        .ball = Ball.init(),
    };

    return game_state;
}

// this is called after the dll is rebuilt
export fn gameReload(game_state_ptr: *anyopaque) void {
    const game_state: *GameState = @ptrCast(@alignCast(game_state_ptr));
    _ = game_state;
}

export fn gameTick(game_state_ptr: *anyopaque) void {
    const game_state: *GameState = @ptrCast(@alignCast(game_state_ptr));
    _ = game_state;
}

export fn gameDraw(game_state_ptr: *anyopaque) void {
    const game_state: *GameState = @ptrCast(@alignCast(game_state_ptr));
    _ = game_state;
    rl.ClearBackground(rl.BLACK);
}
