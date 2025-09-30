#include "raylib.h"

const auto WIDTH =     960;
const auto HEIGHT =    960;
const auto CELL_SIZE = 6;
const auto ROWS =      int(HEIGHT / CELL_SIZE);
const auto COLS =      int(WIDTH / CELL_SIZE);
const Color GREY       {29, 29, 29, 255};
const Color DARK_GREY  {55, 55, 55, 255};

bool running =              false;
auto fps =                  int(12);
int cells[COLS][ROWS] =     {0};
int tmp_cells[COLS][ROWS] = {0};

auto updateGame() -> void;

auto main() -> int {
    InitWindow(WIDTH, HEIGHT, "Conway's Game of Life");
    SetTargetFPS(fps);

    while (!WindowShouldClose()) updateGame();
    CloseWindow();
}

auto drawCells() -> void {
	for (int row {0}; row < ROWS; row++) {
		for (int column {0}; column < COLS; column++) {
			Color color;
			if (cells[row][column] == 1) color = GREEN;
            else color = DARK_GREY;
			DrawRectangle(int(column * CELL_SIZE), int(row * CELL_SIZE), int(CELL_SIZE - 1), int(CELL_SIZE - 1), color);
		}
	}
}

auto fillRandom() -> void {
	if (!running) {
		for (int row {0}; row < ROWS; row++) {
		    for (int column {0}; column < COLS; column++) {
				auto random = GetRandomValue(0, 3);
				if (random == 1) cells[row][column] = 1;
				else cells[row][column] = 0;
			}
		}
	}
}

auto clearGrid() -> void {
	if (!running) {
		for (int row {0}; row < ROWS; row++) {
		    for (int column {0}; column < COLS; column++) {
				cells[row][column] = 0;
			}
		}
	}
}

auto countLiveNbrs(int row, int col) -> int {
	int c0 = (col - 1 + COLS) % COLS;
	int c1 = col;
	int c2 = (col + 1) % COLS;
	auto r0 = cells[(row - 1 + ROWS) % ROWS];
	auto r1 = cells[row];
	auto r2 = cells[(row + 1) % ROWS];

	return r0[c0] + r0[c1] + r0[c2] + r1[c0] + r1[c2] + r2[c0] + r2[c1] + r2[c2];
}

auto updateSim() -> void {
	if (running) {
		for (int row {0}; row < ROWS; row++) {
		    for (int column {0}; column < COLS; column++) {
				auto live_nbrs = countLiveNbrs(row, column);
				auto cell_value = cells[row][column];

				if (cell_value == 1) {
					if (live_nbrs > 3 || live_nbrs < 2) tmp_cells[row][column] = 0;
					else tmp_cells[row][column] = 1;
				}
				else {
					if (live_nbrs == 3) tmp_cells[row][column] = 1;
					else tmp_cells[row][column] = 0;
				}
			}
		}

		for (int row {0}; row < ROWS; row++) {
		    for (int column {0}; column < COLS; column++) {
				cells[row][column] = tmp_cells[row][column];
			}
		}
	}
}

auto gameControls() -> void {
	if (IsKeyPressed(KEY_ENTER)) running = !running;
	if (IsKeyPressed(KEY_R)) fillRandom();
	if (IsKeyPressed(KEY_C)) clearGrid();
	if (IsKeyPressed(KEY_F) || IsKeyPressed(KEY_S)) {
		if (IsKeyPressed(KEY_F)) fps += 2;
		if (IsKeyPressed(KEY_S) && fps > 5) fps -= 2;
		SetTargetFPS(fps);
	}
	
}
auto draw_game() -> void {
    BeginDrawing();
    ClearBackground(GREY);
    drawCells();
    EndDrawing();
}

auto updateGame() -> void {
	gameControls();
	updateSim();
	draw_game();

	if (running) SetWindowTitle(TextFormat("Game of Life is Running at %d", fps));
	else SetWindowTitle("Game of Life is Paused");
}
