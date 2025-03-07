-- the idea is to set the minimal values here as constants, and the rest relative to those
ScreenWidth = 800
ScreenHeight = 600

WhiteColor = { 0.95, 0.75, 0.6 }
BlackColor = { 0.84, 0.6, 0.5 }
--BlackColor = { 0.875, 0.6, 0.5 }

DarkGreyColor = { 0.2, 0.2, 0.2 }
DarkGreenColor = { 0.0, 0.5, 0.0 }
SoftGray = { 0.8, 0.8, 0.8 } -- Soft light gray color


SpritePieceSize = 200 -- this doesn't change, given the sprite png I am using


function CalculateRelativeScreenVariables()
    SquareSize = math.floor((ScreenHeight * 0.9) / 8)
    BoardWidth = SquareSize * 8
    BoardHeight = SquareSize * 8 -- this just makes it clearer when reading code
    PieceScaleFactor = SquareSize / SpritePieceSize

    LabelFontSize = math.floor(SquareSize / 6)

    FileLabelOffsetX = math.floor(SquareSize * 0.8)
    FileLabelOffsetY = math.floor(SquareSize * 0.26)
    RankLabelOffsetX = math.floor(SquareSize * 0.1)
    RankLabelOffsetY = math.floor(SquareSize * 0.1)
end

CalculateRelativeScreenVariables()
