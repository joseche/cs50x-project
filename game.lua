local game = {}

function game.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    Sprites = love.graphics.newImage("resources/pieces.png")
    LabelFont = love.graphics.newFont("resources/labelFont.ttf", LabelFontSize)

    WKing = love.graphics.newQuad(0, 0, SpritePieceSize, SpritePieceSize, Sprites)
    WQueen = love.graphics.newQuad(SpritePieceSize, 0, SpritePieceSize, SpritePieceSize, Sprites)
    WBishop = love.graphics.newQuad(2 * SpritePieceSize, 0, SpritePieceSize, SpritePieceSize, Sprites)
    WKnight = love.graphics.newQuad(3 * SpritePieceSize, 0, SpritePieceSize, SpritePieceSize, Sprites)
    WRook = love.graphics.newQuad(4 * SpritePieceSize, 0, SpritePieceSize, SpritePieceSize, Sprites)
    WPawn = love.graphics.newQuad(5 * SpritePieceSize, 0, SpritePieceSize, SpritePieceSize, Sprites)

    BKing = love.graphics.newQuad(0, SpritePieceSize, SpritePieceSize, SpritePieceSize, Sprites)
    BQueen = love.graphics.newQuad(SpritePieceSize, SpritePieceSize, SpritePieceSize, SpritePieceSize, Sprites)
    BBishop = love.graphics.newQuad(2 * SpritePieceSize, SpritePieceSize, SpritePieceSize, SpritePieceSize, Sprites)
    BKnight = love.graphics.newQuad(3 * SpritePieceSize, SpritePieceSize, SpritePieceSize, SpritePieceSize, Sprites)
    BRook = love.graphics.newQuad(4 * SpritePieceSize, SpritePieceSize, SpritePieceSize, SpritePieceSize, Sprites)
    BPawn = love.graphics.newQuad(5 * SpritePieceSize, SpritePieceSize, SpritePieceSize, SpritePieceSize, Sprites)
end

game.draw = function()
    love.graphics.clear(SoftGray) -- Dark gray background for contrast

    game.draw_empty_board()
    game.draw_pieces_start_position()
end

game.draw_colors = function()
    -- Set background color
    love.graphics.clear(DarkGreyColor) -- Dark gray background for contrast

    -- Set and draw the color
    love.graphics.setColor(WhiteColor)
    love.graphics.rectangle("fill", 100, 100, 200, 200)
    love.graphics.setColor(WhiteColor)
    love.graphics.print("White Color", 130, 80)

    love.graphics.setColor(BlackColor)
    love.graphics.rectangle("fill", 300, 300, 200, 200)
    love.graphics.print("Black Color", 330, 280)
end

game.draw_empty_board = function()
    love.graphics.setColor(WhiteColor)
    love.graphics.rectangle("fill", 0, 0, BoardWidth, BoardWidth)
    love.graphics.setColor(BlackColor)
    for x = 0, 7 do
        for y = 0, 7 do
            if (x + y) % 2 == 1 then
                love.graphics.rectangle("fill", x * SquareSize, y * SquareSize, SquareSize, SquareSize)
            end
        end
    end
    -- Chessboard labels
    local files = { "a", "b", "c", "d", "e", "f", "g", "h" }
    local ranks = { "8", "7", "6", "5", "4", "3", "2", "1" }
    love.graphics.setFont(LabelFont)
    local file_color
    local rank_color

    for i = 0, 7 do
        local x_pos = i * SquareSize
        local y_pos = i * SquareSize
        if i % 2 == 0 then
            file_color = WhiteColor
            rank_color = BlackColor
        else
            file_color = BlackColor
            rank_color = WhiteColor
        end
        love.graphics.setColor(rank_color)
        love.graphics.print(ranks[i + 1], RankLabelOffsetX, y_pos + RankLabelOffsetY)
        love.graphics.setColor(file_color)
        love.graphics.print(files[i + 1], x_pos + FileLabelOffsetX, BoardHeight - FileLabelOffsetY)
    end
end

game.draw_pieces_start_position = function()
    love.graphics.setColor(1, 1, 1)

    -- draw black pawns
    for x = 0, 7 do
        y_pos = 1 * SquareSize
        love.graphics.draw(Sprites, BPawn, x * SquareSize, y_pos, 0, PieceScaleFactor)
    end

    -- draw white pawns
    for x = 0, 7 do
        y_pos = 6 * SquareSize
        love.graphics.draw(Sprites, WPawn, x * SquareSize, y_pos, 0, PieceScaleFactor)
    end

    -- Draw black rooks
    love.graphics.draw(Sprites, BRook, 0 * SquareSize, 0 * SquareSize, 0, PieceScaleFactor)
    love.graphics.draw(Sprites, BRook, 7 * SquareSize, 0 * SquareSize, 0, PieceScaleFactor)

    -- Draw white rooks
    love.graphics.draw(Sprites, WRook, 0 * SquareSize, 7 * SquareSize, 0, PieceScaleFactor)
    love.graphics.draw(Sprites, WRook, 7 * SquareSize, 7 * SquareSize, 0, PieceScaleFactor)

    -- Draw black knights
    love.graphics.draw(Sprites, BKnight, 1 * SquareSize, 0 * SquareSize, 0, PieceScaleFactor)
    love.graphics.draw(Sprites, BKnight, 6 * SquareSize, 0 * SquareSize, 0, PieceScaleFactor)

    -- Draw white knights
    love.graphics.draw(Sprites, WKnight, 1 * SquareSize, 7 * SquareSize, 0, PieceScaleFactor)
    love.graphics.draw(Sprites, WKnight, 6 * SquareSize, 7 * SquareSize, 0, PieceScaleFactor)

    -- Draw black bishops
    love.graphics.draw(Sprites, BBishop, 2 * SquareSize, 0 * SquareSize, 0, PieceScaleFactor)
    love.graphics.draw(Sprites, BBishop, 5 * SquareSize, 0 * SquareSize, 0, PieceScaleFactor)

    -- Draw white bishops
    love.graphics.draw(Sprites, WBishop, 2 * SquareSize, 7 * SquareSize, 0, PieceScaleFactor)
    love.graphics.draw(Sprites, WBishop, 5 * SquareSize, 7 * SquareSize, 0, PieceScaleFactor)

    -- Draw black queen
    love.graphics.draw(Sprites, BQueen, 3 * SquareSize, 0 * SquareSize, 0, PieceScaleFactor)

    -- Draw white queen
    love.graphics.draw(Sprites, WQueen, 3 * SquareSize, 7 * SquareSize, 0, PieceScaleFactor)

    -- Draw black king
    love.graphics.draw(Sprites, BKing, 4 * SquareSize, 0 * SquareSize, 0, PieceScaleFactor)

    -- Draw white king
    love.graphics.draw(Sprites, WKing, 4 * SquareSize, 7 * SquareSize, 0, PieceScaleFactor)
end

return game
