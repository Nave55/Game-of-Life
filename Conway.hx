class Conway extends hxd.App {
    static inline var CELL_SIZE = 6;
    static inline var HEIGHT = 960;
    static inline var WIDTH = 960;
    static inline var ROWS = Std.int(HEIGHT / CELL_SIZE);
    static inline var COLS = Std.int(WIDTH / CELL_SIZE);

    var elements: Array<Array<h2d.SpriteBatch.BatchElement>> = [];
    var cells: Array<Array<Int>> = [];
    var tmp_cells: Array<Array<Int>> = [];
    var running = false;
    var gen = hxd.Rand.create();
    var elapsedTime: Float = 0.0;
    var updateInterval: Float = 1.0 / 12.0;
    var green_tile: h2d.Tile;
    var dark_grey_tile: h2d.Tile;

    static function main() {
        new Conway();
    }

    function drawCells() {
        for (row in 0...ROWS) {
            for (col in 0...COLS) {
                elements[row][col].t = (cells[row][col] == 1) ? green_tile : dark_grey_tile;
            }
        }
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
                for (col in 0...COLS) {
                    var live_neighbors = countLiveNbrs(row, col);
                    var cell_value = cells[row][col];
    
                    tmp_cells[row][col] = if (cell_value == 1) {
                        if (live_neighbors < 2 || live_neighbors > 3) 0 else 1;
                    } else {
                        if (live_neighbors == 3) 1 else 0;
                    };
                }
           }

            for (row in 0...ROWS) {
                for (col in 0...COLS) {
                    if (cells[row][col] != tmp_cells[row][col]) {
                        cells[row][col] = tmp_cells[row][col];
                        elements[row][col].t = (cells[row][col] == 1) ? green_tile : dark_grey_tile;
                    }
                }
            }
        }
    }

    override function init() {
        super.init();

        engine.backgroundColor = 0x373737;
        green_tile = h2d.Tile.fromColor(0x00e430, CELL_SIZE - 1, CELL_SIZE - 1);
        dark_grey_tile = h2d.Tile.fromColor(0x1d1d1d, CELL_SIZE - 1, CELL_SIZE - 1);

        var batch = new h2d.SpriteBatch(dark_grey_tile, s2d);
        for (row in 0...ROWS) {
            var rowElems = [];
            for (col in 0...COLS) {
                var elem = batch.alloc(dark_grey_tile);
                elem.x = col * CELL_SIZE;
                elem.y = row * CELL_SIZE;
                rowElems.push(elem);
            }
            elements.push(rowElems);
        }

        cells = [for (_ in 0...ROWS) [for (_ in 0...COLS) 0]];
        tmp_cells = [for (i in cells) [for (j in i) j]];
    }
    
    override function update(dt: Float) {
        super.update(dt);
        if (hxd.Key.isPressed(hxd.Key.R) && !running) fillRandom();
        if (hxd.Key.isPressed(hxd.Key.C) && !running) clearGrid();
        if (hxd.Key.isPressed(hxd.Key.ENTER)) running = !running;
        if (hxd.Key.isPressed(hxd.Key.S)) updateInterval += .005;
        if (hxd.Key.isPressed(hxd.Key.F) && updateInterval >= .005) updateInterval -= .005;

        var fps = (60 / (60 * updateInterval));
        hxd.Window.getInstance().title = 'Conway running at ${fps} fps';
        
        elapsedTime += dt; 
        if (elapsedTime >= updateInterval) { 
            updateSim();
            elapsedTime -= updateInterval; // Reset elapsed time 
        }       
    }
}
