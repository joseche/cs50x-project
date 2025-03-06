-- the idea is to set the minimal values here as constants, and the rest relative to those
ScreenWidth = 1200
ScreenHeight = 800

SpritePieceSize = 200 -- this doesn't change, given the sprite png I am using


SquareSize = math.floor((ScreenHeight * 0.9) / 8)
BoardWidth = SquareSize * 8
PieceScaleFactor = SquareSize / SpritePieceSize
SquareLabelXoffset = math.floor(SquareSize * 0.8)
SquareLabelYoffset = math.floor(SquareSize * 0.1)

WhiteColor = { 0.95, 0.75, 0.6 }
BlackColor = { 0.875, 0.6, 0.5 }
