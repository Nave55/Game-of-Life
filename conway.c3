const int WIDTH =       960;
const int HEIGHT =      960;
const int CELL_SIZE =   6;
const int ROWS =        (int) HEIGHT / CELL_SIZE;
const int COLS =        (int) WIDTH / CELL_SIZE;
const Color GREEN =     {0, 228, 48, 255};
const Color GREY =      {29, 29, 29, 255};
const Color DARK_GREY = {55, 55, 55, 255};

bool running =              false;
int fps =                   12;
int[COLS][ROWS] cells =     {};
int[COLS][ROWS] tmp_cells = {};

fn void main(String[] args) {
	init_window(WIDTH, HEIGHT, "Conway's Game of Life");
	defer close_window();
    set_target_fps(fps);

    while (!window_should_close()) update_game();
}

fn void draw_cells() {
	for (int row = 0; row < ROWS; row += 1) {
		for (int column = 0; column < COLS; column += 1) {
			Color color = (cells[row][column] == 1) ? GREEN : GREY;
			draw_rectangle(
				(int) column * CELL_SIZE, 
				(int) row * CELL_SIZE, 
				(int) CELL_SIZE - 1, 
				(int) CELL_SIZE - 1, 
				color
			);
		}
	}
}

fn void fill_random() {
	if (!running) {
		for (int row = 0; row < ROWS; row += 1) {
		    for (int column = 0; column < COLS; column += 1) {
				cells[row][column] = get_random_value(0, 3) == 1 ? 1 : 0;
			}
		}
	}
}

fn void clear_grid() {
	if (!running) {
		for (int row = 0; row < ROWS; row += 1) {
		    for (int column = 0; column < COLS; column += 1) {
				cells[row][column] = 0;
			}
		}
	}
}

fn int count_live_nbrs(int row, int col) {
	int   c0 = (col - 1 + COLS) % COLS;
	int   c1 = col;
	int   c2 = (col + 1) % COLS;
	int[] r0 = &cells[(row - 1 + ROWS) % ROWS];
	int[] r1 = &cells[row];
	int[] r2 = &cells[(row + 1) % ROWS];

	return r0[c0] + r0[c1] + r0[c2] + r1[c0] + r1[c2] + r2[c0] + r2[c1] + r2[c2];
}

fn void update_sim() {
	if (running) {
		for (int row = 0; row < ROWS; row += 1) {
		    for (int column = 0; column < COLS; column += 1) {
				int live_nbrs = count_live_nbrs(row, column);
				int cell_value = cells[row][column];

				if (cell_value == 1) {
					tmp_cells[row][column] = (live_nbrs > 3 || live_nbrs < 2) ? 0 : 1;
				}
				else {
					tmp_cells[row][column] = (live_nbrs == 3) ? 1 : 0;
				}
			}
		}

		for (int row = 0; row < ROWS; row += 1) {
		    for (int column = 0; column < COLS; column += 1) {
				cells[row][column] = tmp_cells[row][column];
			}
		}
	}
}

fn void game_controls() {
	if (is_key_pressed(Key.ENTER)) running = !running;
	if (is_key_pressed(Key.R)) fill_random();
	if (is_key_pressed(Key.C)) clear_grid();
	if (is_key_pressed(Key.F) || is_key_pressed(Key.S)) {
		if (is_key_pressed(Key.F)) fps += 2;
		if (is_key_pressed(Key.S) && fps > 5) fps -= 2;
		set_target_fps(fps);
	}
}

fn void draw_game(){
    begin_drawing();
	defer end_drawing();
    clear_background(DARK_GREY);
    draw_cells();
}

fn void update_game() {
	game_controls();
	update_sim();
	draw_game();

	if (running) {
		set_window_title(text_format("Game of Life is Running at %d", fps));
	} else { 
		set_window_title("Game of Life is Paused");
	}
}
