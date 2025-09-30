package conway

/*******************************************************************************************
*
*   Conway's Game of Life
* 
*   Original version https://github.com/educ8s/Python-Game-Of-Life-with-Pygame
*   Original video tutorial https://www.youtube.com/watch?v=uR0lNADr4dc
*
*   Original by Programming With Nick @(educ8s)
*   Translation to Odin by Evan Martinez (@Nave55)
*
********************************************************************************************/

import rl "vendor:raylib"

WIDTH :: 960
HEIGHT :: 960
CELL_SIZE :: 6
ROWS :: int(HEIGHT / CELL_SIZE)
COLS :: int(WIDTH / CELL_SIZE)
GREY: rl.Color : {29, 29, 29, 255}
DARK_GREY: rl.Color : {55, 55, 55, 255}
fps: i32 = 12
running := false
cells: [COLS][ROWS]int
tmp_cells := cells

main :: proc() {
	rl.InitWindow(WIDTH, HEIGHT, "Game of Life")
	defer rl.CloseWindow()
	rl.SetTargetFPS(fps)

	for !rl.WindowShouldClose() do updateGame()
}

drawCells :: proc() {
	for row in 0 ..< ROWS {
		for column in 0 ..< COLS {
			color := cells[row][column] == 1 ? rl.GREEN : DARK_GREY
			rl.DrawRectangle(
				i32(column * CELL_SIZE),
				i32(row * CELL_SIZE),
				i32(CELL_SIZE - 1),
				i32(CELL_SIZE - 1),
				color,
			)
		}
	}
}

fillRandom :: proc() {
	if !running {
		for row in 0 ..< ROWS {
			for column in 0 ..< COLS {
				random := rl.GetRandomValue(0, 3)
				if random == 1 do cells[row][column] = 1
				else do cells[row][column] = 0
			}
		}
	}
}

clearGrid :: proc() {
	if !running {
		for row in 0 ..< ROWS {
			for column in 0 ..< COLS {
				cells[row][column] = 0
			}
		}
	}
}

countLiveNeighbors :: proc(row, col: int) -> (live_neighbors := 0) {
	c0 := (col - 1 + COLS) % COLS
	c1 := col
	c2 := (col + 1) % COLS
	r0 := cells[(row - 1 + ROWS) % ROWS]
	r1 := cells[row]
	r2 := cells[(row + 1) % ROWS]

	return r0[c0] + r0[c1] + r0[c2] + r1[c0] + r1[c2] + r2[c0] + r2[c1] + r2[c2]
}

updateSim :: proc() {
	if running {
		for row in 0 ..< ROWS {
			for column in 0 ..< COLS {
				live_neighbors := countLiveNeighbors(row, column)
				cell_value := cells[row][column]

				if cell_value == 1 {
					if live_neighbors > 3 || live_neighbors < 2 do tmp_cells[row][column] = 0
					else do tmp_cells[row][column] = 1
				} else {
					if live_neighbors == 3 do tmp_cells[row][column] = 1
					else do tmp_cells[row][column] = 0
				}
			}
		}
		for row in 0 ..< ROWS {
			for column in 0 ..< COLS {
				cells[row][column] = tmp_cells[row][column]
			}
		}
	}
}

controls :: proc() {
	if rl.IsKeyPressed(.ENTER) do running = !running
	if rl.IsKeyPressed(.R) do fillRandom()
	if rl.IsKeyPressed(.C) do clearGrid()
	if rl.IsKeyPressed(.F) || rl.IsKeyPressed(.S) {
		if rl.IsKeyPressed(.F) do fps += 2
		if rl.IsKeyPressed(.S) && fps > 5 do fps -= 2
		rl.SetTargetFPS(fps)
	}
}

drawGame :: proc() {
	rl.BeginDrawing()
	defer rl.EndDrawing()

	rl.ClearBackground(GREY)
	drawCells()
}

updateGame :: proc() {
	controls()
	updateSim()
	drawGame()
	if running do rl.SetWindowTitle(rl.TextFormat("Game of Life is Running at %v fps", fps))
	else do rl.SetWindowTitle("Game of Life is Paused")
}

