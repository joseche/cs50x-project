-- the idea is to set the minimal values here as constants, and the rest relative to those
ScreenWidth = 800
ScreenHeight = 600

WhiteColor = { 0.95, 0.75, 0.6 }
BlackColor = { 0.84, 0.6, 0.5 }
--BlackColor = { 0.875, 0.6, 0.5 }

DarkGreyColor = { 0.2, 0.2, 0.2 }
DarkGreenColor = { 0.0, 0.5, 0.0 }
SoftGray = { 0.8, 0.8, 0.8 } -- Soft light gray color


PieceSpriteSize = 200 -- this doesn't change, given the sprite png I am using
BoardTileSpriteSize = 64



function CalculateRelativeScreenVariables()
    SquareSize = math.floor(ScreenHeight / 8)
    BoardWidth = SquareSize * 8
    BoardHeight = SquareSize * 8 -- this just makes it clearer when reading code
    PieceScaleFactor = SquareSize / PieceSpriteSize

    LabelFontSize = math.floor(SquareSize / 6)
    MenuFontSize = math.floor(SquareSize / 4)

    FileLabelOffsetX = math.floor(SquareSize * 0.8)
    FileLabelOffsetY = math.floor(SquareSize * 0.26)
    RankLabelOffsetX = math.floor(SquareSize * 0.1)
    RankLabelOffsetY = math.floor(SquareSize * 0.1)

    MainMenu_X = math.floor(SquareSize * 8.5)
    MainMenu_Y = math.floor(SquareSize * 0.5)
end

CalculateRelativeScreenVariables()
