import raylib, random, strformat

const
  WIDTH =     1020
  HEIGHT =    1020
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
      var color: Color
      if cells[row][column] == 1: 
        color = Green
      else:
        color = DARK_GREY

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
      
proc countLiveNbrs(row, column: int): int = 
  const nbr_offsets = [[-1, -1], [-1, 0], [-1, 1], [0, -1], [0, 1], [1, -1], [1, 0], [1, 1]]
  var live_nbrs = 0
  for offset in nbr_offsets:
    var 
      new_row = (row + offset[0]) %% ROWS
      new_column = (column + offset[1]) %% COlS
    if cells[new_row][new_column] == 1:
      live_nbrs += 1

  return live_nbrs

proc updateSim = 
  if running:
    for row in 0..<ROWS:
      for column in 0..<COLS:
        var
          live_nbrs = countLiveNbrs(row, column)
          cell_value = cells[row][column]

        if cell_value == 1:
          if live_nbrs > 3 or live_nbrs < 2:
            tmp_cells[row][column] = 0
          else:
            tmp_cells[row][column] = 1
        else:
          if live_nbrs == 3:
            tmp_cells[row][column] = 1
          else:
            tmp_cells[row][column] = 0

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
    setWindowTitle(cstring(&"Game of Life is Running at {fps}"))
  else:
    setWindowTitle(cstring("Game of Life is Paused"))
  controls()
  updateSim()
  drawGame()

block:
  initWindow(WIDTH, HEIGHT, "Game of Life")
  defer: closeWindow()
  setTargetFPS(fps)
  
  while not windowShouldClose():
    updateGame()