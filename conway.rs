use raylib::prelude::*;

static GREY: Color = Color {
    r: 29,
    g: 29,
    b: 29,
    a: 255,
};
static DARK_GREY: Color = Color {
    r: 55,
    g: 55,
    b: 55,
    a: 255,
};

fn main() {
    const WIDTH: i32 = 1020;
    const HEIGHT: i32 = 1020;
    const CELL_SIZE: usize = 6;
    const ROWS: usize = (HEIGHT / CELL_SIZE as i32) as usize;
    const COLS: usize = (WIDTH / CELL_SIZE as i32) as usize;

    let mut fps: u32 = 12;
    let mut running = false;
    let mut cells: Vec<Vec<u32>> = vec![vec![0; COLS]; ROWS];
    let mut tmp_cells: Vec<Vec<u32>> = vec![vec![0; COLS]; ROWS];

    let (mut rl, thread) = init()
        .size(WIDTH, HEIGHT)
        .title("Conway's Game of Life")
        .build();

    rl.set_target_fps(fps);

    while !rl.window_should_close() {
        controls(&mut running, &mut rl, ROWS, COLS, &mut cells, &mut fps);
        update_sim(running, ROWS, COLS, &mut cells, &mut tmp_cells);
        draw_game(&mut rl, &thread, &cells, ROWS, COLS, CELL_SIZE);
        set_tile(&mut rl, &thread, fps, running);
    }
}

fn controls(
    running: &mut bool,
    rl: &mut RaylibHandle,
    rows: usize,
    cols: usize,
    cells: &mut Vec<Vec<u32>>,
    fps: &mut u32,
) {
    if rl.is_key_pressed(KeyboardKey::KEY_ENTER) {
        *running = !*running;
    }
    if rl.is_key_pressed(KeyboardKey::KEY_R) {
        fill_random(rl, running, rows, cols, cells)
    }
    if rl.is_key_pressed(KeyboardKey::KEY_C) {
        clear_grid(running, rows, cols, cells);
    }
    if rl.is_key_pressed(KeyboardKey::KEY_S) || rl.is_key_pressed(KeyboardKey::KEY_F) {
        if rl.is_key_pressed(KeyboardKey::KEY_F) {
            *fps += 2;
        }
        if rl.is_key_pressed(KeyboardKey::KEY_S) && *fps > 5 {
            *fps -= 2;
        }
        rl.set_target_fps(*fps);
    }
}

fn draw_game(
    rl: &mut RaylibHandle,
    thread: &RaylibThread,
    cells: &Vec<Vec<u32>>,
    rows: usize,
    cols: usize,
    cell_size: usize,
) {
    let mut draw = rl.begin_drawing(thread);
    draw.clear_background(GREY);
    draw_cells(&mut draw, cells, rows, cols, cell_size);
}

fn set_tile(rl: &mut RaylibHandle, thread: &RaylibThread, fps: u32, running: bool) {
    if running {
        rl.set_window_title(
            thread,
            format!("Game of Life is Running at {}", fps).as_str(),
        );
    } else {
        rl.set_window_title(thread, "Game of Life is Paused");
    }
}

fn draw_cells(
    draw: &mut RaylibDrawHandle,
    cells: &Vec<Vec<u32>>,
    rows: usize,
    cols: usize,
    cell_size: usize,
) {
    for row in 0..rows {
        for col in 0..cols {
            let color: Color;
            if cells[row][col] == 1 {
                color = Color::GREEN;
            } else {
                color = DARK_GREY;
            }
            draw.draw_rectangle(
                (col * cell_size) as i32,
                (row * cell_size) as i32,
                (cell_size - 1) as i32,
                (cell_size - 1) as i32,
                color,
            );
        }
    }
}

fn fill_random(
    rl: &mut RaylibHandle,
    running: &bool,
    rows: usize,
    cols: usize,
    cells: &mut Vec<Vec<u32>>,
) {
    if !running {
        for row in 0..rows {
            for col in 0..cols {
                let random: i32 = rl.get_random_value(0..3);
                if random == 1 {
                    cells[row][col] = 1;
                } else {
                    cells[row][col] = 0;
                }
            }
        }
    }
}

fn clear_grid(running: &bool, rows: usize, cols: usize, cells: &mut Vec<Vec<u32>>) {
    if !running {
        for row in 0..rows {
            for col in 0..cols {
                cells[row][col] = 0;
            }
        }
    }
}

fn count_live_nbrs(
    row: usize,
    col: usize,
    cells: &mut Vec<Vec<u32>>,
    rows: usize,
    cols: usize,
) -> i32 {
    let nbr_offsets: [[i32; 2]; 8] = [
        [-1, -1],
        [-1, 0],
        [-1, 1],
        [0, -1],
        [0, 1],
        [1, -1],
        [1, 0],
        [1, 1],
    ];

    let mut live_nbrs = 0;

    for offset in nbr_offsets {
        let new_row = (row as i32 + offset[0]).rem_euclid(rows as i32) as usize;
        let new_col = (col as i32 + offset[1]).rem_euclid(cols as i32) as usize;
        if cells[new_row][new_col] == 1 {
            live_nbrs += 1;
        }
    }

    live_nbrs
}

fn update_sim(
    running: bool,
    rows: usize,
    cols: usize,
    cells: &mut Vec<Vec<u32>>,
    tmp_cells: &mut Vec<Vec<u32>>,
) {
    if running {
        for row in 0..rows {
            for col in 0..cols {
                let live_nbrs = count_live_nbrs(row, col, cells, rows, cols);
                let cell_value = cells[row][col];

                if cell_value == 1 {
                    if live_nbrs > 3 || live_nbrs < 2 {
                        tmp_cells[row][col] = 0;
                    } else {
                        tmp_cells[row][col] = 1;
                    }
                } else {
                    if live_nbrs == 3 {
                        tmp_cells[row][col] = 1;
                    } else {
                        tmp_cells[row][col] = 0;
                    }
                }
            }
        }

        for row in 0..rows {
            for col in 0..cols {
                cells[row][col] = tmp_cells[row][col];
            }
        }
    }
}
