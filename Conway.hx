typedef AAI = Array<Array<Int>>;

class Conway extends hxd.App {
    // constants 
    static inline var CELL_SIZE = 6;
    static inline var HEIGHT = 1000;
    static inline var WIDTH = 1000;
    static inline var GREEN = 0x00e430;
    static inline var GREY = 0x373737;
    static inline var DARK_GREY = 0x1d1d1d;
    static inline var ROWS = Std.int(HEIGHT / CELL_SIZE);
    static inline var COLS = Std.int(WIDTH / CELL_SIZE);

    // globals
    var cells: AAI = [];
    var tmp_cells: AAI = [];
    var running = false;
    var gen = hxd.Rand.create();
    var graphics: h2d.Graphics;
    var elapsedTime: Float = 0.0;
    var updateInterval: Float = 1.0 / 12.0;

    static function main() {
        new Conway();
    }

    function fillRandom() {
        if (!running) {
            for (row in 0...ROWS) {
                for (column in 0...COLS) {
                    cells[row][column] = (gen.random(4) == 1) ? 1 : 0;
                }
            }
            drawCells();
        }
    }

    function drawCells() {
        graphics.clear(); // Clear previous drawing
        for (row in 0...ROWS) {
            for (column in 0...COLS) {
                var color = (cells[row][column] == 1) ? GREEN : DARK_GREY;
                graphics.beginFill(color);
                graphics.drawRect(column * CELL_SIZE, row * CELL_SIZE, CELL_SIZE - 1, CELL_SIZE - 1);
                graphics.endFill();
            }
        }
    }

    function clearGrid() {
        if (!running) {
            for (row in 0...ROWS) {
                for (column in 0...COLS) {
                    cells[row][column] = 0;
                }
            }
            drawCells();
        }
    }

    function countLiveNbrs(row: Int, column: Int): Int {
        var live_neighbors = 0;
        var offsets = [[-1, -1], [-1, 0], [-1, 1], [0, -1], [0, 1], [1, -1], [1, 0], [1, 1]];
        for (offset in offsets) {
            var new_row = (row + offset[0] + ROWS) % ROWS;
            var new_column = (column + offset[1] + COLS) % COLS;
            live_neighbors += cells[new_row][new_column];
        }
        return live_neighbors;
    }

    function updateSim() {
        if (running) {
            for (row in 0...ROWS) {
                for (column in 0...COLS) {
                    var live_neighbors = countLiveNbrs(row, column);
                    var cell_value = cells[row][column];
    
                    tmp_cells[row][column] = if (cell_value == 1) {
                        if (live_neighbors < 2 || live_neighbors > 3) 0 else 1;
                    } else {
                        if (live_neighbors == 3) 1 else 0;
                    };
                }
           }
            for (row in 0...ROWS) {
                for (column in 0...COLS) {
                    if (cells[row][column] != tmp_cells[row][column]) {
                        cells[row][column] = tmp_cells[row][column];
                        var color = (cells[row][column] == 1) ? GREEN : DARK_GREY;
                        graphics.beginFill(color);
                        graphics.drawRect(column * CELL_SIZE, row * CELL_SIZE, CELL_SIZE - 1, CELL_SIZE - 1);
                        graphics.endFill();
                    }
                }
            }
        }
    }

    override function init() {
        super.init();

        var bg = new h2d.Graphics(s2d);
        bg.beginFill(GREY);
        bg.drawRect(0, 0, s2d.width, s2d.height);
        bg.endFill();
        graphics = new h2d.Graphics(s2d);

        cells = [for (_ in 0...ROWS) [for (_ in 0...COLS) 0]];
        tmp_cells = [for (i in cells) [for (j in i) j]];

        drawCells();
    }
    
    override function update(dt: Float) {
        super.update(dt);
        if (hxd.Key.isPressed(hxd.Key.R) && !running) {
            fillRandom();
        } else if (hxd.Key.isPressed(hxd.Key.C) && !running) {
            clearGrid();
        } else if (hxd.Key.isPressed(hxd.Key.ENTER)) {
            running = !running;
        }

        elapsedTime += dt; 
        if (elapsedTime >= updateInterval) { 
            updateSim();
            elapsedTime -= updateInterval; // Reset elapsed time 
        }       
    }
}
