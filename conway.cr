require "./raylib"

module Config
    WIDTH     = 960
    HEIGHT    = 960
    CELL_SIZE = 6
    ROWS      = HEIGHT // CELL_SIZE
    COLS      = WIDTH // CELL_SIZE
    GREEN     = Rl::Color.new(r: 0, g: 228, b: 48, a: 255)
    GREY      = Rl::Color.new(r: 55, g: 55, b: 55, a: 255)
    DARK_GREY = Rl::Color.new(r: 29, g: 29, b: 29, a: 255)
end

class Game
    include Config
    alias Key = Rl::KeyboardKey

    @cells     : Array(Array(Int8))
    @tmp_cells : Array(Array(Int8))

    def initialize(@fps = 12, @running = false)
        @cells     = Array.new(ROWS) { Array.new(COLS, 0_i8) }
        @tmp_cells = Array.new(ROWS) { Array.new(COLS, 0_i8) }
    end

    def each_cell
        (0...ROWS).each do |row|
            (0...COLS).each { |col| yield row, col }
        end
    end

    def draw_cells
        each_cell do |row, column| 
            color = @cells[row][column] == 1 ? GREEN : DARK_GREY
            Rl.draw_rectangle(
                (column * CELL_SIZE), 
                (row * CELL_SIZE), 
                (CELL_SIZE - 1), 
                (CELL_SIZE - 1), 
                color
            )
        end
    end

    def fill_random
        if !@running 
            each_cell do |row, column|                    
                @cells[row][column] = Random.rand(3) == 1 ? 1_i8 : 0_i8
            end
        end
    end

    def clear_grid
        each_cell { |row, column| @cells[row][column] = 0 } if !@running
    end

    def count_live_nbrs(row : Int, col : Int) : Int8
        c0 = (col - 1 + COLS) % COLS
        c1 = col
        c2 = (col + 1) % COLS
        r0 = @cells[(row - 1 + ROWS) % ROWS]
        r1 = @cells[row]
        r2 = @cells[(row + 1) % ROWS]

        r0[c0] + r0[c1] + r0[c2] + r1[c0] + r1[c2] + r2[c0] + r2[c1] + r2[c2]
    end

    def update_sim
        if @running
            each_cell do |row, col|
                live = count_live_nbrs(row, col)
                alive = @cells[row][col] == 1

                @tmp_cells[row][col] =
                    if alive
                        (live == 2 || live == 3) ? 1_i8 : 0_i8
                    else
                        (live == 3) ? 1_i8 : 0_i8
                    end
            end

            @cells, @tmp_cells = @tmp_cells, @cells
        end
    end

    def game_controls
        @running = !@running if Rl.is_key_pressed(Key::Enter)
        fill_random() if Rl.is_key_pressed(Key::R)
        clear_grid() if Rl.is_key_pressed(Key::C)
        if Rl.is_key_pressed(Key::F) || Rl.is_key_pressed(Key::S) 
            @fps += 2 if Rl.is_key_pressed(Key::F)
            @fps -= 2 if  Rl.is_key_pressed(Key::S) && @fps > 5
            Rl.set_target_fps(@fps)
        end
    end

    def draw_game
        Rl.begin_drawing()
        Rl.clear_background(GREY)
        draw_cells()
        Rl.end_drawing()
    end

    def update_game
        game_controls()
        update_sim()
        draw_game()

        if @running 
            Rl.set_window_title("Game of Life is Running at #{@fps} fps");
	    else 
            Rl.set_window_title("Game of Life is Paused");
        end
    end

    def run
        Rl.init_window(WIDTH, HEIGHT, "Hello World")
        Rl.set_target_fps(@fps)
        while !Rl.window_should_close()
            update_game()
        end
        Rl.close_window()
    end
end

Game.new().run()
