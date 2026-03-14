{-# LANGUAGE ForeignFunctionInterface #-}

module Main where

import Foreign.C.Types
import Foreign.C.ConstPtr
import Foreign.C.String
import Control.Monad
import Foreign.Storable
import Data.Word
import Data.Bits ((.|.), shiftL)
import Data.Array.IO

type Color = CUInt

color :: Word8 -> Word8 -> Word8 -> Word8 -> Color
color r g b a =
    fromIntegral r .|.
    (fromIntegral g `shiftL` 8)  .|.
    (fromIntegral b `shiftL` 16) .|.
    (fromIntegral a `shiftL` 24)

data Keys
  = Space
  | C
  | F
  | R
  | S
  | Enter
  deriving (Enum, Show)

key :: Keys -> CInt
key C     = 67
key F     = 70
key R     = 82
key S     = 83
key Enter = 257

foreign import ccall "InitWindow"
  initWindow :: CInt -> CInt -> CString -> IO ()

foreign import ccall "CloseWindow"
  closeWindow :: IO ()

foreign import ccall "WindowShouldClose"
  windowShouldClose :: IO CBool

foreign import ccall "SetTargetFPS"
  setTargetFps :: CInt -> IO ()

foreign import ccall "BeginDrawing"
  beginDrawing :: IO ()

foreign import ccall "EndDrawing"
  endDrawing :: IO ()

foreign import ccall "ClearBackground"
  clearBackground :: CUInt -> IO ()

foreign import ccall "DrawRectangle"
  drawRectangle :: CInt -> CInt -> CInt -> CInt -> CUInt -> IO ()

foreign import ccall "IsKeyPressed"
  isKeyPressed :: CInt -> IO CBool

foreign import ccall "SetWindowTitle"
  setWindowTitle :: CString -> IO ()

foreign import ccall "GetRandomValue"
  getRandomValue :: CInt -> CInt -> IO CInt

initWindow' :: Int -> Int -> String -> IO ()
initWindow' w h title =
  withCString title $ \t ->
    initWindow (fromIntegral w) (fromIntegral h) t

windowShouldClose' :: IO Bool
windowShouldClose' = do
  r <- windowShouldClose
  pure (r /= 0)

isKeyPressed' :: Keys -> IO Bool
isKeyPressed' k = do
  r <- isKeyPressed (key k)
  pure (r /= 0)

getRandomValue' :: Int -> Int -> IO Int
getRandomValue' a b = do
  r <- getRandomValue (fromIntegral a) (fromIntegral b)
  pure (fromIntegral r)

setWindowTitle' :: String -> IO ()
setWindowTitle' title =
  withCString title $ \t -> setWindowTitle t

width :: CInt
width = 960

height :: CInt
height = 960

cellSize :: CInt
cellSize = 6

rows :: CInt
rows = height `div` cellSize

cols :: CInt
cols = width `div` cellSize

green :: Color
green = color 0 228 48 255

grey :: Color
grey = color 55 55 55 255

darkGrey :: Color
darkGrey = color 29 29 29 255

whenM :: Monad m => m Bool -> m () -> m ()
whenM mb action = mb >>= \b -> when b action

type Grid = IOUArray (CInt, CInt) Int

makeGrid :: IO Grid
makeGrid = do
  newArray ((0,0),(rows-1,cols-1)) 0

drawCells :: Grid -> IO ()
drawCells g = do
  forM_ [0 .. rows-1] $ \row ->
    forM_ [0 .. cols-1] $ \col -> do
      v <- readArray g (row, col)
      let color = if v == 1 then green else darkGrey
      drawRectangle
        (col * cellSize)
        (row * cellSize)
        (cellSize - 1)
        (cellSize - 1)
        color

fillRandom :: Grid -> Bool -> IO ()
fillRandom _ True = pure ()
fillRandom g False = do
  forM_ [0 .. rows-1] $ \row ->
    forM_ [0 .. cols-1] $ \col -> do
      r_val <- getRandomValue 0 3
      writeArray g (row, col) $ if r_val == 1 then 1 else 0

clearGrid :: Grid -> Bool -> IO ()
clearGrid _ True = pure ()
clearGrid g False = do
  forM_ [0 .. rows-1] $ \row ->
    forM_ [0 .. cols-1] $ \col -> do
      writeArray g (row, col) 0

countLiveNbrs :: Grid -> CInt -> CInt -> IO Int
countLiveNbrs g row col = do
  let c0 = (col - 1 + cols) `mod` cols
      c1 = col
      c2 = (col + 1) `mod` cols

      r0 = (row - 1 + rows) `mod` rows
      r1 = row
      r2 = (row + 1) `mod` rows

  a <- readArray g (r0, c0)
  b <- readArray g (r0, c1)
  c <- readArray g (r0, c2)

  d <- readArray g (r1, c0)
  e <- readArray g (r1, c2)

  f <- readArray g (r2, c0)
  g' <- readArray g (r2, c1)
  h <- readArray g (r2, c2)

  pure (a + b + c + d + e + f + g' + h)

updateSim :: Grid -> Grid -> Bool -> IO ()
updateSim _ _ False = pure ()
updateSim g t True  = do
  forM_ [0 .. rows-1] $ \row ->
    forM_ [0 .. cols-1] $ \col -> do
      live <- countLiveNbrs g row col
      val  <- readArray g (row, col)
      let newVal
            | val == 1 = if live < 2 || live > 3 then 0 else 1
            | live == 3 = 1
            | otherwise = 0
      writeArray t (row, col) newVal

gameControls :: Grid -> Bool -> CInt -> IO (Bool, CInt)
gameControls grid run fps = do
  whenM (isKeyPressed' R) $ fillRandom grid run
  whenM (isKeyPressed' C) $ clearGrid grid run

  enter <- isKeyPressed' Enter
  fKey  <- isKeyPressed' F
  sKey  <- isKeyPressed' S

  let fps'
        | fKey      = fps + 2
        | sKey      = fps - 2
        | otherwise = fps

  when (fKey || sKey) $ setTargetFps (fromIntegral fps')
  let run' = if enter then not run else run
  pure (run', fps')

drawGame :: Grid -> IO ()
drawGame grid = do
  beginDrawing
  clearBackground grey
  drawCells grid
  endDrawing

updateGame :: Grid -> Grid -> Bool -> CInt -> IO (Grid, Grid, Bool, CInt)
updateGame g t run fps = do
  (run', fps') <- gameControls g run fps
  drawGame g
  if run'
    then do
      setWindowTitle' $
        "Conway's Game of Life is Runnin at " ++ show fps' ++ " fps"
      updateSim g t True
      pure (t, g, run', fps')
    else do
      setWindowTitle' "Conway's Game of Life is Paused"
      pure (g, t, run', fps')

mainLoop g t run fps = do
  quit <- windowShouldClose'
  unless quit $ do
    (g', t', run', fps') <- updateGame g t run fps
    mainLoop g' t' run' fps'

main = do
  initWindow' 960 960 "Conway's Game of Life"
  setTargetFps 12
  grid <- makeGrid
  t_grid <- makeGrid
  mainLoop grid t_grid False 12
  closeWindow
