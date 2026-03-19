import Raylib;

class ConwayRaylib {
    static final WIDTH     = 960;
    static final HEIGHT    = 960;
    static final CELL_SIZE = 6;
    static final ROWS      = Std.int(HEIGHT / CELL_SIZE);
    static final COLS      = Std.int(WIDTH / CELL_SIZE);
    static final SIZE      = ROWS * COLS;
    static final INDEX     = [for (i in 0...ROWS) for (j in 0...COLS) {row: i, col: j}];
    static final NEIGHBORS = makeNeighbors();

    static var running     = false;
    static var fps         = 12;
    static var cells       = [for (_ in 0...SIZE) 0];
    static var tmp_cells   = [for (_ in 0...SIZE) 0];

    static function main() {
        Rl.initWindow(WIDTH, HEIGHT, "Conway's Game of Life (Flat)");
        Rl.setTargetFps(fps);
        while (!Rl.windowShouldClose()) updateGame();
        Rl.closeWindow();
    }

    @:pure 
    static function makeNeighbors(): Array<Array<Int>> {
        var out = new Array<Array<Int>>();
        out.resize(SIZE);

        for (i in 0...SIZE) {
            final rc = INDEX[i];
            final r = rc.row;
            final c = rc.col;

            final r0 = (r - 1 + ROWS) % ROWS;
            final r1 = r;
            final r2 = (r + 1) % ROWS;

            final c0 = (c - 1 + COLS) % COLS;
            final c1 = c;
            final c2 = (c + 1) % COLS;

            out[i] = [
                r0 * COLS + c0,
                r0 * COLS + c1,
                r0 * COLS + c2,
                r1 * COLS + c0,
                r1 * COLS + c2,
                r2 * COLS + c0,
                r2 * COLS + c1,
                r2 * COLS + c2
            ];
        }

        return out;
    }

    static function drawCells(): Void {
        static final GREEN = Color.make(0,228,48,255);
        static final DARK  = Color.make(29,29,29,255);

        for (i in 0...SIZE) {
            final rc = INDEX[i];
            final color = cells[i] == 1 ? GREEN : DARK;

            Rl.drawRectangle(
                rc.col * CELL_SIZE,
                rc.row * CELL_SIZE,
                CELL_SIZE - 1,
                CELL_SIZE - 1,
                color
            );
        }
    }

    static function fillRandom():Void {
        if (!running) {
            for (i in 0...SIZE)
                cells[i] = Std.random(3) == 1 ? 1 : 0;
        }
    }

    static function clearGrid():Void {
        if (!running) {
            for (i in 0...SIZE)
                cells[i] = 0;
        }
    }

    static inline function countLiveNbrs(idx:Int): Int {
        final n = NEIGHBORS[idx];
        return cells[n[0]] + cells[n[1]] + cells[n[2]] +
               cells[n[3]] + cells[n[4]] +
               cells[n[5]] + cells[n[6]] + cells[n[7]];
    }

    static function updateSim():Void {
        if (running) {
            for (i in 0...SIZE) {
                final live = countLiveNbrs(i);
                final cell = cells[i];

                tmp_cells[i] =
                    if (cell == 1)
                        (live < 2 || live > 3) ? 0 : 1
                    else
                        (live == 3) ? 1 : 0;
            }

            final old = cells;
            cells = tmp_cells;
            tmp_cells = old;
        }
    }

    static function gameControls():Void {
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
        static final GREY = Color.make(55,55,55,255);
        Rl.beginDrawing();
        Rl.clearBackground(GREY);
        drawCells();
        Rl.endDrawing();
    }

    static function updateGame():Void {
        gameControls();
        updateSim();
        drawGame();

        if (running)
            Rl.setWindowTitle('Game of Life Running at ${fps} fps');
        else
            Rl.setWindowTitle("Game of Life Paused");
    }
}
