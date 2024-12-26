#include "raylib.h"

const auto width =     1020;
const auto height =    1020;
const auto cell_size = 6;
const auto rows =      int(height / cell_size);
const auto cols =      int(width / cell_size);
const Color grey       {29, 29, 29, 255};
const Color dark_grey  {55, 55, 55, 255};

bool running =              false;
auto fps =                  int(12);
int cells[cols][rows] =     {0};
int tmp_cells[cols][rows] = {0};

auto updateGame() -> void;

auto main() -> int {
    InitWindow(width, height, "Conway's Game of Life");
    SetTargetFPS(fps);

    while (!WindowShouldClose()) updateGame();
    CloseWindow();
}

auto drawCells() -> void {
	for (int row {0}; row < rows; row++) {
		for (int column {0}; column < cols; column++) {
			Color color;
			if (cells[row][column] == 1) color = GREEN;
            else color = dark_grey;
			DrawRectangle(int(column * cell_size), int(row * cell_size), int(cell_size - 1), int(cell_size - 1), color);
		}
	}
}

auto fillRandom() -> void {
	if (!running) {
		for (int row {0}; row < rows; row++) {
		    for (int column {0}; column < cols; column++) {
				auto random = GetRandomValue(0, 3);
				if (random == 1) cells[row][column] = 1;
				else cells[row][column] = 0;
			}
		}
	}
}

auto clearGrid() -> void {
	if (!running) {
		for (int row {0}; row < rows; row++) {
		    for (int column {0}; column < cols; column++) {
				cells[row][column] = 0;
			}
		}
	}
}

auto countLiveNbrs(int row, int column) -> int {
	int nbr_offsets[8][2] = {{-1, -1}, {-1, 0}, {-1, 1}, {0, -1}, {0, 1}, {1, -1}, {1, 0}, {1, 1}};
	int  live_nbrs = 0;
	for (auto const &offset : nbr_offsets) {
		auto new_row = int(row + offset[0] % rows);
		auto new_column = int(column + offset[1] % cols);
		if (cells[new_row][new_column] == 1) live_nbrs += 1;
	}

	return live_nbrs;
}

auto updateSim() -> void {
	if (running) {
		for (int row {0}; row < rows; row++) {
		    for (int column {0}; column < cols; column++) {
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

		for (int row {0}; row < rows; row++) {
		    for (int column {0}; column < cols; column++) {
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
    ClearBackground(grey);
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
