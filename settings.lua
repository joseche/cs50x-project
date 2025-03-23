dofile("globals.lua")
local settings = {}

function settings.update_square_size()
    local menu_width = math.max(MenuMinWidth, ScreenWidth - 8 * (ScreenHeight / 8))
    local board_width = ScreenWidth - menu_width
    local square_size = math.min(board_width / 8, ScreenHeight / 8)
    print("updating square size to " .. tostring(square_size))
    return square_size
end

function settings.update_relative_vars() -- has all global vars updated as side-effect, not pretty
    print("updating relative variable to screen size")
    SquareSize = settings.update_square_size()
    local SquareSize = SquareSize

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

return settings
