import nave.raylibv as rl
import math

const width = 960
const height = 960
const cell_size = 6
const rows = int(height / cell_size)
const cols = int(width / cell_size)
const grey = rl.Color{
	r: 29
	g: 29
	b: 29
	a: 255
}
const dark_grey = rl.Color{
	r: 55
	g: 55
	b: 55
	a: 255
}

struct Game {
mut:
	running   bool
	fps       i32 = 12
	cells     [][]int
	tmp_cells [][]int
}

fn main() {
	rl.init_window(width, height, 'Game of Life'.str)
	defer { rl.close_window }
	rl.set_target_fps(12)
	mut game := &Game{}
	game.init_game()

	for !rl.window_should_close() {
		game.game_controls()
		game.update_game()
	}
}

fn (mut game Game) init_game() {
	game.cells = [][]int{len: cols, cap: cols, init: []int{len: rows, cap: rows, init: 0}}
	game.tmp_cells = [][]int{len: cols, cap: cols, init: []int{len: rows, cap: rows, init: 0}}
}

fn (mut game Game) game_controls() {
	if rl.is_key_pressed(rl.key_enter) {
		game.running = !game.running
	}
	if rl.is_key_pressed(rl.key_r) {
		fill_random(mut game.cells, game.running)
	}
	if rl.is_key_pressed(rl.key_c) {
		clear_grid(mut game.cells, game.running)
	}

	if rl.is_key_pressed(rl.key_f) || rl.is_key_pressed(rl.key_s) {
		if rl.is_key_pressed(rl.key_f) {
			game.fps += 2
		}
		if rl.is_key_pressed(rl.key_s) && game.fps > 5 {
			game.fps -= 2
		}
		rl.set_target_fps(game.fps)
	}
}

fn draw_game(mut cells [][]int) {
	rl.begin_drawing()
	defer { rl.end_drawing() }
	rl.clear_background(grey)

	draw_cells(mut cells)
}

fn (mut game Game) update_game() {
	update_sim(mut game)
	draw_game(mut game.cells)

	if game.running {
		rl.set_window_title('Game of Life is Running at ${game.fps}'.str)
	} else {
		rl.set_window_title('Game of Life is Paused'.str)
	}
}

fn draw_cells(mut cells [][]int) {
	for row in 0 .. rows {
		for column in 0 .. cols {
			mut color := rl.Color{}
			if cells[row][column] == 1 {
				color = rl.green
			} else {
				color = dark_grey
			}
			rl.draw_rectangle(i32(column * cell_size), i32(row * cell_size), i32(cell_size - 1),
				i32(cell_size - 1), color)
		}
	}
}

fn fill_random(mut cells [][]int, running bool) {
	if !running {
		for row in 0 .. rows {
			for column in 0 .. cols {
				random := rl.get_random_value(0, 3)
				if random == 1 {
					cells[row][column] = 1
				} else {
					cells[row][column] = 0
				}
			}
		}
	}
}

fn clear_grid(mut cells [][]int, running bool) {
	if !running {
		for row in 0 .. rows {
			for column in 0 .. cols {
				cells[row][column] = 0
			}
		}
	}
}

fn count_live_nbrs(mut cells [][]int, row int, column int) int {
	nbr_offsets := [[-1, -1], [-1, 0], [-1, 1], [0, -1], [0, 1],
		[1, -1], [1, 0], [1, 1]]
	mut live_nbrs := 0
	for offset in nbr_offsets {
		new_row := int(math.modulo_floored(row + offset[0], rows))
		new_column := int(math.modulo_floored(column + offset[1], cols))
		if cells[new_row][new_column] == 1 {
			live_nbrs += 1
		}
	}

	return live_nbrs
}

fn update_sim(mut game Game) {
	if game.running {
		for row in 0 .. rows {
			for column in 0 .. cols {
				live_nbrs := count_live_nbrs(mut game.cells, row, column)
				cell_value := game.cells[row][column]

				if cell_value == 1 {
					if live_nbrs > 3 || live_nbrs < 2 {
						game.tmp_cells[row][column] = 0
					} else {
						game.tmp_cells[row][column] = 1
					}
				} else {
					if live_nbrs == 3 {
						game.tmp_cells[row][column] = 1
					} else {
						game.tmp_cells[row][column] = 0
					}
				}
			}
		}

		for row in 0 .. rows {
			for column in 0 .. cols {
				game.cells[row][column] = game.tmp_cells[row][column]
			}
		}
	}
}
