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
    var green_tile: h2d.Tile;
    var dark_grey_tile: h2d.Tile;
    var updatesPerSecond:Float = 12;
    var updateInterval:Float = 1.0 / 12;
    var elapsedTime:Float = 0;

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
        final c0 = (column - 1 + COLS) % COLS;
        final c1 = column;
        final c2 = (column + 1) % COLS;
        final r0 = cells[(row - 1 + ROWS) % ROWS];
        final r1 = cells[row];
        final r2 = cells[(row + 1) % ROWS];

        return r0[c0] + r0[c1] + r0[c2] + r1[c0] + r1[c2] + r2[c0] + r2[c1] + r2[c2];
    }

    function updateSim() {
        if (!running) return;

        var changed: Array<Int> = [];

        for (row in 0...ROWS) {
            final rowCells = cells[row];
            final rowTmp = tmp_cells[row];
            for (col in 0...COLS) {
                final live_neighbors = countLiveNbrs(row, col);
                final cell_value = rowCells[col];
                final newValue = if (cell_value == 1) {
                    (live_neighbors < 2 || live_neighbors > 3) ? 0 : 1;
                } else {
                    (live_neighbors == 3) ? 1 : 0;
                };

                if (newValue != rowTmp[col]) {
                    rowTmp[col] = newValue;
                    changed.push(row * COLS + col);
                }
            }
        }

        for (idx in changed) {
            final r = Std.int(idx / COLS);
            final c = idx - r * COLS;
            final newVal = tmp_cells[r][c];
            if (cells[r][c] != newVal) {
                cells[r][c] = newVal;
                elements[r][c].t = (newVal == 1) ? green_tile : dark_grey_tile;
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
        hxd.Window.getInstance().title = 'Conway running at ${Std.int(updatesPerSecond)} fps';

        if (hxd.Key.isReleased(hxd.Key.ENTER)) running = !running;
        if (hxd.Key.isReleased(hxd.Key.R) && !running) fillRandom();
        if (hxd.Key.isReleased(hxd.Key.C) && !running) clearGrid();

        if (hxd.Key.isReleased(hxd.Key.F)) {
            updatesPerSecond = Math.min(updatesPerSecond + 1, 240);
            updateInterval = 1.0 / updatesPerSecond;
        }
        if (hxd.Key.isReleased(hxd.Key.S)) {
            updatesPerSecond = Math.max(updatesPerSecond - 1, 1);
            updateInterval = 1.0 / updatesPerSecond;
        }

        elapsedTime += dt;
        while (elapsedTime >= updateInterval) {
            updateSim();
            elapsedTime -= updateInterval;
        }
    }
}


