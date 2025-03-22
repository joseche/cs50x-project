-- the idea is to set the minimal values here as constants, and the rest relative to those
ScreenWidth = 800
ScreenHeight = 600
MinScreenWidth = 800
MinScreenHeight = 600

MenuMinWidth = 200

WhiteColor = { 0.95, 0.75, 0.6 }
BlackColor = { 0.84, 0.6, 0.5 }
--BlackColor = { 0.875, 0.6, 0.5 }

DarkGreyColor = { 0.2, 0.2, 0.2 }
DarkGreenColor = { 0.0, 0.5, 0.0 }
SoftGray = { 0.8, 0.8, 0.8 } -- Soft light gray color

SelectedSquareColor = { 0.4, 0.6, 0.1 }

PieceSpriteSize = 200 -- this doesn't change, given the sprite png I am using
BoardTileSpriteSize = 64

RatingRoundingFactor = 5
DefaultRating = 400

UserRatingsFile = "ChessPuzzlesUserRating.txt"
ResolvedPuzzlesFile = "ChessResolvedPuzzles.txt"

function Calculate_square_size()
    local menu_width = math.max(MenuMinWidth, ScreenWidth - 8 * (ScreenHeight / 8))
    local board_width = ScreenWidth - menu_width
    local square_size = math.min(board_width / 8, ScreenHeight / 8)
    return square_size
end

function CalculateRelativeScreenVariables() -- has all global vars updated as side-effect, not pretty
    SquareSize = Calculate_square_size()

    BoardWidth = SquareSize * 8
    BoardHeight = SquareSize * 8 -- this just makes it clearer when reading code
    PieceScaleFactor = SquareSize / PieceSpriteSize

    LabelFontSize = math.floor(SquareSize / 6)
    MenuFontSize = math.floor(SquareSize / 5)
    RatingFontSize = math.floor(SquareSize / 6)
    RatingPopUpFontSize = math.floor(SquareSize * 2)

    FileLabelOffsetX = math.floor(SquareSize * 0.8)
    FileLabelOffsetY = math.floor(SquareSize * 0.26)
    RankLabelOffsetX = math.floor(SquareSize * 0.1)
    RankLabelOffsetY = math.floor(SquareSize * 0.1)


    MainMenu_X = math.floor((SquareSize * 8) + 20)
    MainMenu_Y = math.floor(SquareSize * 6)
    MainMenu_Width = ScreenWidth - MainMenu_X - 10
end

CalculateRelativeScreenVariables()
