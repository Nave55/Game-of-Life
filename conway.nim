import raylib, random, strformat

const
  WIDTH =     960
  HEIGHT =    960
  CELL_SIZE = 6
  ROWS =      int(HEIGHT / CELL_SIZE)
  COLS =      int(WIDTH / CELL_SIZE)
  GREY =      Color(r: 29, g: 29, b: 29, a: 255)
  DARK_GREY = Color(r: 55, g: 55, b: 55, a: 255)

var 
  cells:       array[COLS, array[ROWS, int]]
  tmp_cells =  cells
  running =    false
  fps: int32 = 12
  
proc drawCells = 
  for row in 0..<ROWS:
    for column in 0..<COLS:
      let color =  if cells[row][column] == 1: Green else: DARK_GREY
      drawRectangle(int32(column * CELL_SIZE), 
                    int32(row * CELL_SIZE),
                    int32(CELL_SIZE - 1),
                    int32(CELL_SIZE - 1),
                    color)

proc fillRandom = 
  if not running: 
    for row in 0..<ROWS:
      for column in 0..<COLS:
        let random = rand(3)
        if random == 1: 
          cells[row][column] = 1 
        else:
          cells[row][column] = 0

proc clearGrid =
  if not running:
    for row in 0..<ROWS:
      for column in 0..<COLS:
        cells[row][column] = 0
      
proc countLiveNbrs(row, col: int): int = 
  let
    c0 = (col - 1 + COLS) mod COLS
    c1 = col
    c2 = (col + 1) mod COLS
    r0 = cells[(row - 1 + ROWS) mod ROWS]
    r1 = cells[row]
    r2 = cells[(row + 1) mod ROWS]

  return r0[c0] + r0[c1] + r0[c2] + r1[c0] + r1[c2] + r2[c0] + r2[c1] + r2[c2]

proc updateSim = 
  if running:
    for row in 0..<ROWS:
      for column in 0..<COLS:
        let live_nbrs = countLiveNbrs(row, column)
        var cell_value = cells[row][column]

        tmp_cells[row][column] = if cell_value == 1:
          if live_nbrs > 3 or live_nbrs < 2:
            0
          else:
            1
        else:
          if live_nbrs == 3:
            1
          else:
            0

    for row in 0..<ROWS:
      for column in 0..<COLS:
        cells[row][column] = tmp_cells[row][column]

proc controls = 
  if isKeyPressed(Enter):
    running = not running
  if isKeyPressed(R): 
    fillRandom()
  if isKeyPressed(C):
    clearGrid()
  
  if isKeyPressed(F) or isKeyPressed(S):
    if isKeyPressed(F):
      fps += 2
    if isKeyPressed(S) and fps > 5:
      fps -= 2
    setTargetFPS(fps)

proc drawGame = 
  beginDrawing()
  defer: endDrawing()  

  clearBackground(GREY)
  drawCells()

proc updateGame = 
  if running:
    setWindowTitle(&"Game of Life is Running at {fps}")
  else:
    setWindowTitle("Game of Life is Paused")
  controls()
  updateSim()
  drawGame()

block:
  initWindow(WIDTH, HEIGHT, "Game of Life")
  defer: closeWindow()
  setTargetFPS(fps)
  
  while not windowShouldClose():
    updateGame()
