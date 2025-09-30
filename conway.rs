use raylib::prelude::*;

const GREY: Color = Color {
    r: 29,
    g: 29,
    b: 29,
    a: 255,
};
const DARK_GREY: Color = Color {
    r: 55,
    g: 55,
    b: 55,
    a: 255,
};
const GREEN: Color = Color {
    g: 228,
    r: 0,
    b: 48,
    a: 255,
};

const WIDTH: i32 = 960;
const HEIGHT: i32 = 960;
const CELL_SIZE: usize = 6;
const ROWS: usize = (HEIGHT / CELL_SIZE as i32) as usize;
const COLS: usize = (WIDTH / CELL_SIZE as i32) as usize;

fn main() {
    let mut fps: u32 = 12;
    let mut running = false;
    let mut cells: [[u32; COLS]; ROWS] = [[0; COLS]; ROWS];
    let mut tmp_cells: [[u32; COLS]; ROWS] = [[0; COLS]; ROWS];

    let (mut rl, thread) = init()
        .size(WIDTH, HEIGHT)
        .title("Conway's Game of Life")
        .build();

    rl.set_target_fps(fps);

    while !rl.window_should_close() {
        controls(&mut running, &mut rl, &mut cells, &mut fps);
        update_sim(running, &mut cells, &mut tmp_cells);
        draw_game(&mut rl, &thread, &cells, CELL_SIZE);
        set_title(&mut rl, &thread, fps, running);
    }
}

fn controls(
    running: &mut bool,
    rl: &mut RaylibHandle,
    cells: &mut [[u32; COLS]; ROWS],
    fps: &mut u32,
) {
    if rl.is_key_pressed(KeyboardKey::KEY_ENTER) {
        *running = !*running;
    }
    if rl.is_key_pressed(KeyboardKey::KEY_R) {
        fill_random(rl, running, ROWS, COLS, cells)
    }
    if rl.is_key_pressed(KeyboardKey::KEY_C) {
        clear_grid(running, ROWS, COLS, cells);
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
    cells: &[[u32; COLS]; ROWS],
    cell_size: usize,
) {
    let mut draw = rl.begin_drawing(thread);
    draw.clear_background(GREY);
    draw_cells(&mut draw, cells, ROWS, COLS, cell_size);
}

fn set_title(rl: &mut RaylibHandle, thread: &RaylibThread, fps: u32, running: bool) {
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
    cells: &[[u32; COLS]; ROWS],
    rows: usize,
    cols: usize,
    cell_size: usize,
) {
    for row in 0..rows {
        for col in 0..cols {
            let color: Color = if cells[row][col] == 1 {
                GREEN
            } else {
                DARK_GREY
            };
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
    cells: &mut [[u32; COLS]; ROWS],
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

fn clear_grid(running: &bool, rows: usize, cols: usize, cells: &mut [[u32; COLS]; ROWS]) {
    if !running {
        for row in 0..rows {
            for col in 0..cols {
                cells[row][col] = 0;
            }
        }
    }
}

fn count_live_nbrs(row: usize, col: usize, cells: &[[u32; COLS]; ROWS]) -> i32 {
    let c0 = (col + COLS - 1) % COLS;
    let c1 = col;
    let c2 = (col + 1) % COLS;
    let r0 = (row + ROWS - 1) % ROWS;
    let r1 = row;
    let r2 = (row + 1) % ROWS;

    let row0 = &cells[r0];
    let row1 = &cells[r1];
    let row2 = &cells[r2];

    (row0[c0] + row0[c1] + row0[c2] + row1[c0] + row1[c2] + row2[c0] + row2[c1] + row2[c2]) as i32
}

fn update_sim(running: bool, cells: &mut [[u32; COLS]; ROWS], tmp_cells: &mut [[u32; COLS]; ROWS]) {
    if running {
        for row in 0..ROWS {
            for col in 0..COLS {
                let live_nbrs = count_live_nbrs(row, col, cells);
                let cell_value = cells[row][col];

                tmp_cells[row][col] = if cell_value == 1 {
                    if live_nbrs > 3 || live_nbrs < 2 {
                        0
                    } else {
                        1
                    }
                } else {
                    if live_nbrs == 3 {
                        1
                    } else {
                        0
                    }
                }
            }
        }

        for row in 0..ROWS {
            for col in 0..COLS {
                cells[row][col] = tmp_cells[row][col];
            }
        }
    }
}
