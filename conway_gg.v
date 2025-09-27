module main

import gg
import rand
import math

const width = 720
const height = 720
const cell_size = 6
const rows = height / cell_size
const cols = width / cell_size
const green = gg.rgb(0, 228, 48)
const grey = gg.rgb(29, 29, 29)
const dark_grey = gg.rgb(55, 55, 55)

struct Game {
mut:
	gg        &gg.Context = unsafe { nil }
	running   bool
	cells     [][]int
	tmp_cells [][]int
}

fn main() {
	mut game := &Game{}
	game.gg = gg.new_context(
		bg_color:      grey
		width:         width
		height:        height
		window_title:  'Conway'
		user_data:     game
		event_fn:      on_event
		frame_fn:      frame
	)

	game.init_game()
	game.gg.run()
}

fn (mut game Game) init_game() {
	game.cells = [][]int{len: cols, init: []int{len: rows, init: 0}}
	game.tmp_cells = [][]int{len: cols, init: []int{len: rows, init: 0}}
}

fn frame(mut game Game) {
		game.gg.begin()

		game.update_game()
		game.gg.end()
}

fn (mut game Game) key_down(key gg.KeyCode) ! {
	match key {
		.escape {
			game.gg.quit()
		}
		.enter {
			game.running = !game.running
		}
		.r {
			fill_random(mut game.cells, game.running)
		}
		.c {
			clear_grid(mut game.cells, game.running)
		}
		else {}
	}
}

fn on_event(e &gg.Event, mut game Game) {
	if e.typ == .key_down {
		game.key_down(e.key_code) or {}
	}
}

fn (mut game Game) update_game() {
	if game.gg.frame % 5 == 0 {
		update_sim(mut game)
	}
	draw_cells(mut game)
}

fn draw_cells(mut game Game) {
	for row in 0 .. rows {
		for column in 0 .. cols {
			mut color := gg.Color{}
			if game.cells[row][column] == 1 {
				color = green
			} else {
				color = dark_grey
			}
			game.gg.draw_rect_filled(column * cell_size, row * cell_size, cell_size - 1,
					cell_size - 1, color)
		}
	}
}

fn fill_random(mut cells [][]int, running bool) {
	if !running {
		for row in 0 .. rows {
			for column in 0 .. cols {
				random := rand.int_in_range(0, 3) or { 0 }
				cells[row][column] = if random == 1 { 1 } else { 0 }
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
