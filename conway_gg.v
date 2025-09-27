module main

import gg
import rand
import time

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
	updates_per_sec f64 = 12.0
	update_interval f64 = 1.0 / 12.0
	acc             f64
	last_nano       i64
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
		swap_interval: 1
	)

	game.init_game()
	game.last_nano = time.now().unix_nano()
	game.gg.run()
}

fn (mut game Game) init_game() {
	game.cells = [][]int{len: rows, init: []int{len: cols, init: 0}}
	game.tmp_cells = [][]int{len: rows, init: []int{len: cols, init: 0}}
}

fn frame(mut game Game) {
	game.gg.begin()

	now := time.now().unix_nano()
	dt := f64(now - game.last_nano) / 1e9
	game.last_nano = now
	game.acc += dt

	for game.acc >= game.update_interval {
		update_sim(mut game)
		game.acc -= game.update_interval
	}

	draw_cells(mut game)
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
			fill_random(mut game)
		}
		.c {
			clear_grid(mut game)
		}
		else {}
	}
}

fn on_event(e &gg.Event, mut game Game) {
	if e.typ == .key_down {
		game.key_down(e.key_code) or {}
	}
}

fn draw_cells(mut game Game) {
	for row in 0 .. rows {
		for column in 0 .. cols {
			color := if game.cells[row][column] == 1 { green } else { dark_grey }
			game.gg.draw_rect_filled(column * cell_size, row * cell_size, cell_size - 1,
				cell_size - 1, color)
		}
	}
}

fn fill_random(mut game Game) {
	if !game.running {
		for row in 0 .. rows {
			for column in 0 .. cols {
				random := rand.int_in_range(0, 3) or { 0 }
				game.cells[row][column] = if random == 1 { 1 } else { 0 }
			}
		}
	}
}

fn clear_grid(mut game Game) {
	if !game.running {
		for row in 0 .. rows {
			for column in 0 .. cols {
				game.cells[row][column] = 0
			}
		}
	}
}

fn count_live_nbrs(cells [][]int, row int, column int) int {
    c0 := (column - 1 + cols) % cols
    c1 := column
    c2 := (column + 1) % cols
    r0 := cells[(row - 1 + rows) % rows]
    r1 := cells[row]
    r2 := cells[(row + 1) % rows]

    return r0[c0] + r0[c1] + r0[c2] + r1[c0] + r1[c2] + r2[c0] + r2[c1] + r2[c2]
}

fn update_sim(mut game Game) {
	if game.running {
		for row in 0 .. rows {
			for column in 0 .. cols {
				live_nbrs := count_live_nbrs(game.cells, row, column)
				cell_value := game.cells[row][column]

				if cell_value == 1 {
					game.tmp_cells[row][column] = if live_nbrs < 2 || live_nbrs > 3 { 0 } else { 1 }
				} else {
					game.tmp_cells[row][column] = if live_nbrs == 3 { 1 } else { 0 }
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
