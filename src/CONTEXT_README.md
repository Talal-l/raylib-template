# CONTEXT README

main.zig contains dynamic library loading, reloading and unloading functions.
game.zig contains the entry point for the game logic.
when building with zig build you can pass in a -Dhot_reload with either true or false to specify
a hot reloading build.
The plan will be to move the key bindings to an external folder
KEY BINDINGS:
R, hot reloads
X | Q, quit the application

game.zig:
gameInit
gameTick
gameDraw
gameReload

gameInit, creates and returns the Omega game state (for the entire game) to main, which keeps track of the game state for us across hot reloads
gameTick and gameDraw do as their names suggest
gameReload takes in a gamestate is called whenever the game is hot reloaded.
