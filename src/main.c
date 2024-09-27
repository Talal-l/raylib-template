#include "raylib.h"
#include "raymath.h"

const int SCREEN_WIDTH = 400;
const int SCREEN_HEIGHT = 400;

int main_()
{
    InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "TEMPLATE");
    SetTargetFPS(60);

    while (!WindowShouldClose())
    {

        BeginDrawing();

        EndDrawing();
    }

    CloseWindow();
    return 0;
}
