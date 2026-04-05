#include "raylib.h"
#include <array>

const int WIDTH =     960;
const int HEIGHT =    960;
const int CELL_SIZE = 6;
const int ROWS =      HEIGHT / CELL_SIZE;
const int COLS =      WIDTH / CELL_SIZE;
const Color GREY      {29, 29, 29, 255};
const Color DARK_GREY {55, 55, 55, 255};

bool running =              false;
int fps =                   12;
int cells[ROWS][COLS] =     {0};
int tmp_cells[ROWS][COLS] = {0};


auto updateGame() -> void;

auto main() -> int {
    InitWindow(WIDTH, HEIGHT, "Conway's Game of Life");
    SetTargetFPS(fps);

    while (!WindowShouldClose()) updateGame();
    CloseWindow();
}

auto drawCells() -> void {
	for (int r {0}; r < ROWS; r++) {
		for (int c {0}; c < COLS; c++) 
			DrawRectangle(
				int(c * CELL_SIZE), 
				int(r * CELL_SIZE), 
				int(CELL_SIZE - 1), 
				int(CELL_SIZE - 1), 
				(cells[r][c] == 1) ? GREEN : DARK_GREY
			);
	}		
}

auto fillRandom() -> void {
	if (!running) {
		for (int r {0}; r < ROWS; r++) {
			for (int c {0}; c < COLS; c++) 
				cells[r][c] = (GetRandomValue(0, 3) == 1) ? 1 : 0;
		}
	}
}

auto clearGrid() -> void {
	if (!running) {
		for (int r {0}; r < ROWS; r++) {
			for (int c {0}; c < COLS; c++) 
				cells[r][c] = 0;
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
		for (int r {0}; r < ROWS; r++) {
			for (int c {0}; c < COLS; c++) {
				auto live_nbrs = countLiveNbrs(r, c);
				auto cell_value = cells[r][c];

				if (cell_value == 1) {
					tmp_cells[r][c] = (live_nbrs > 3 || live_nbrs < 2) ? 0 : 1;
				} else {
					tmp_cells[r][c] = (live_nbrs == 3) ? 1 : 0;
				}
			}
		}

		for (int r {0}; r < ROWS; r++) {
			for (int c {0}; c < COLS; c++) 
				cells[r][c] = tmp_cells[r][c];
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
