import Raylib;

class ConwayRaylib {
    static final WIDTH     = 960;
    static final HEIGHT    = 960;
    static final CELL_SIZE = 6;
    static final ROWS      = Std.int(HEIGHT / CELL_SIZE);
    static final COLS      = Std.int(WIDTH / CELL_SIZE);
    static var   running   = false;
    static var   fps       = 12;
    static var   cells     = [for (i in 0...COLS) [for (j in 0...ROWS) 0]];
    static var   tmp_cells = [for (i in 0...COLS) [for (j in 0...ROWS) 0]];
	
    extern static inline function green(): Color { return Color.make(0,228,48,255); };
    extern static inline function darkGrey(): Color { return Color.make(29,29,29,255); };
    extern static inline function grey(): Color { return Color.make(55,55,55,255); };
    
    static function main() {
        Rl.initWindow(WIDTH, HEIGHT, "Conway's Game of Life");
        Rl.setTargetFps(fps);
        while (!Rl.windowShouldClose()) updateGame();
        Rl.closeWindow();
    }

    static function drawCells(): Void {
        for (row in 0...ROWS) {
            for (column in 0...COLS) {
                final color = cells[row][column] == 1 ? green() : darkGrey();
                Rl.drawRectangle(
                    (column * CELL_SIZE), 
                    (row * CELL_SIZE), 
                    (CELL_SIZE - 1), 
                    (CELL_SIZE - 1), 
                    color
                );
		    }
	    }
    }

    static function fillRandom(): Void {
        if (!running) {
            for (row in 0...ROWS) {
                for (column in 0...COLS) {
                    cells[row][column] = Std.random(3) == 1 ? 1 : 0;
                }
            }
        }
    }

    static function clearGrid(): Void {
        if (!running) {
            for (row in 0...ROWS) {
                for (column in 0...COLS) {
                    cells[row][column] = 0;
                }
            }
        }
    }

    static function countLiveNbrs(row: Int, col: Int): Int {
        final c0 = (col - 1 + COLS) % COLS;
        final c1 = col;
        final c2 = (col + 1) % COLS;
        final r0 = cells[(row - 1 + ROWS) % ROWS];
        final r1 = cells[row];
        final r2 = cells[(row + 1) % ROWS];

        return r0[c0] + r0[c1] + r0[c2] + r1[c0] + r1[c2] + r2[c0] + r2[c1] + r2[c2];
    }

    static function updateSim(): Void {
        if (running) {
            for (row in 0...ROWS) {
                for (column in 0...COLS) {
                    final live_nbrs = countLiveNbrs(row, column);
                    final cell_value = cells[row][column];

                    if (cell_value == 1) {
                        tmp_cells[row][column] = (live_nbrs > 3 || live_nbrs < 2) ? 0 : 1;
                    } else tmp_cells[row][column] = (live_nbrs == 3) ? 1 : 0;
                    
                }
            }

            for (row in 0...ROWS) {
                for (column in 0...COLS) {
                    cells[row][column] = tmp_cells[row][column];
                }
            }
        }
    }

    static function gameControls(): Void {
        if (Rl.isKeyPressed(Key.ENTER)) running = !running;
        if (Rl.isKeyPressed(Key.R)) fillRandom();
        if (Rl.isKeyPressed(Key.C)) clearGrid();
        if (Rl.isKeyPressed(Key.F) || Rl.isKeyPressed(Key.S)) {
            if (Rl.isKeyPressed(Key.F)) fps += 2;
            if (Rl.isKeyPressed(Key.S) && fps > 5) fps -= 2;
            Rl.setTargetFps(fps);
        }
    }

    static function drawGame() {
        Rl.beginDrawing();
        Rl.clearBackground(grey());
        drawCells();
        Rl.endDrawing();
    }

    static function updateGame(): Void {
        gameControls();
        updateSim();
        drawGame();

        if (running) Rl.setWindowTitle('Game of Life is Running at ${fps} fps');
	    else Rl.setWindowTitle("Game of Life is Paused");
    }
}
import Raylib;

class Clr {
    extern public static inline function darkGrey(): Color { return Color.make(29,29,29,255); }
    extern public static inline function grey(): Color { return Color.make(55,55,55,255); }
    extern public static inline function green(): Color { return Color.make(0,228,48,255); }
}

class ConwayRaylib {
    static final WIDTH     = 960;
    static final HEIGHT    = 960;
    static final CELL_SIZE = 6;
    static final ROWS      = Std.int(HEIGHT / CELL_SIZE);
    static final COLS      = Std.int(WIDTH / CELL_SIZE);
    static var   running   = false;
    static var   fps       = 12;
    static var   cells     = [for (i in 0...COLS) [for (j in 0...ROWS) 0]];
    static var   tmp_cells = [for (i in 0...COLS) [for (j in 0...ROWS) 0]];

    static function main() {
        Rl.initWindow(WIDTH, HEIGHT, "Conway's Game of Life");
        Rl.setTargetFps(fps);
        while (!Rl.windowShouldClose()) updateGame();
        Rl.closeWindow();
    }

    static function drawCells(): Void {
        for (row in 0...ROWS) {
            for (column in 0...COLS) {
                final color = cells[row][column] == 1 ? Clr.green() : Clr.darkGrey();
                Rl.drawRectangle(
                    (column * CELL_SIZE), 
                    (row * CELL_SIZE), 
                    (CELL_SIZE - 1), 
                    (CELL_SIZE - 1), 
                    color
                );
		    }
	    }
    }

    static function fillRandom(): Void {
        if (!running) {
            for (row in 0...ROWS) {
                for (column in 0...COLS) {
                    cells[row][column] = Std.random(3) == 1 ? 1 : 0;
                }
            }
        }
    }

    static function clearGrid(): Void {
        if (!running) {
            for (row in 0...ROWS) {
                for (column in 0...COLS) {
                    cells[row][column] = 0;
                }
            }
        }
    }

    static function countLiveNbrs(row: Int, col: Int): Int {
        final c0 = (col - 1 + COLS) % COLS;
        final c1 = col;
        final c2 = (col + 1) % COLS;
        final r0 = cells[(row - 1 + ROWS) % ROWS];
        final r1 = cells[row];
        final r2 = cells[(row + 1) % ROWS];

        return r0[c0] + r0[c1] + r0[c2] + r1[c0] + r1[c2] + r2[c0] + r2[c1] + r2[c2];
    }

    static function updateSim(): Void {
        if (running) {
            for (row in 0...ROWS) {
                for (column in 0...COLS) {
                    final live_nbrs = countLiveNbrs(row, column);
                    final cell_value = cells[row][column];

                    if (cell_value == 1) {
                        tmp_cells[row][column] = (live_nbrs > 3 || live_nbrs < 2) ? 0 : 1;
                    } else tmp_cells[row][column] = (live_nbrs == 3) ? 1 : 0;
                    
                }
            }

            for (row in 0...ROWS) {
                for (column in 0...COLS) {
                    cells[row][column] = tmp_cells[row][column];
                }
            }
        }
    }

    static function gameControls(): Void {
        if (Rl.isKeyPressed(Key.ENTER)) running = !running;
        if (Rl.isKeyPressed(Key.R)) fillRandom();
        if (Rl.isKeyPressed(Key.C)) clearGrid();
        if (Rl.isKeyPressed(Key.F) || Rl.isKeyPressed(Key.S)) {
            if (Rl.isKeyPressed(Key.F)) fps += 2;
            if (Rl.isKeyPressed(Key.S) && fps > 5) fps -= 2;
            Rl.setTargetFps(fps);
        }
    }

    static function drawGame() {
        Rl.beginDrawing();
        Rl.clearBackground(Clr.grey());
        drawCells();
        Rl.endDrawing();
    }

    static function updateGame(): Void {
        gameControls();
        updateSim();
        drawGame();

        if (running) Rl.setWindowTitle('Game of Life is Running at ${fps} fps');
	    else Rl.setWindowTitle("Game of Life is Paused");
    }
}
