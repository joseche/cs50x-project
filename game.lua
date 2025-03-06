local game = {}

function game.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    Sprites = love.graphics.newImage("resources/pieces.png")
    WKing = love.graphics.newQuad(0, 0, SpritePieceSize, SpritePieceSize, Sprites)
    WQueen = love.graphics.newQuad(SpritePieceSize, 0, SpritePieceSize, SpritePieceSize, Sprites)
    WBishop = love.graphics.newQuad(2 * SpritePieceSize, 0, SpritePieceSize, SpritePieceSize, Sprites)
    WKnight = love.graphics.newQuad(3 * SpritePieceSize, 0, SpritePieceSize, SpritePieceSize, Sprites)
    WPawn = love.graphics.newQuad(4 * SpritePieceSize, 0, SpritePieceSize, SpritePieceSize, Sprites)

    BKing = love.graphics.newQuad(0, SpritePieceSize, SpritePieceSize, SpritePieceSize, Sprites)
    BQueen = love.graphics.newQuad(SpritePieceSize, SpritePieceSize, SpritePieceSize, SpritePieceSize, Sprites)
    BBishop = love.graphics.newQuad(2 * SpritePieceSize, SpritePieceSize, SpritePieceSize, SpritePieceSize, Sprites)
    BKnight = love.graphics.newQuad(3 * SpritePieceSize, SpritePieceSize, SpritePieceSize, SpritePieceSize, Sprites)
    BPawn = love.graphics.newQuad(4 * SpritePieceSize, SpritePieceSize, SpritePieceSize, SpritePieceSize, Sprites)
end

game.draw = function()
    game.draw_empty_board()
    -- game.draw_colors()

    -- love.graphics.setColor(1, 1, 1)
    -- love.graphics.draw(Sprites, WKing, 0, 0, 0, PieceScaleFactor)
    -- love.graphics.draw(Sprites, WQueen, SquareSize, 0, 0, PieceScaleFactor)
    -- love.graphics.draw(Sprites, WBishop, 2 * SquareSize, 0, 0, PieceScaleFactor)

    -- love.graphics.draw(Sprites, BKing, 0, SquareSize, 0, PieceScaleFactor)
    -- love.graphics.draw(Sprites, BQueen, SquareSize, SquareSize, 0, PieceScaleFactor)
    -- love.graphics.draw(Sprites, BBishop, 2 * SquareSize, SquareSize, 0, PieceScaleFactor)
end

game.draw_colors = function()
    -- Set background color
    love.graphics.clear(0.2, 0.2, 0.2) -- Dark gray background for contrast

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
    local coords_font = love.graphics.newFont(14)
    love.graphics.setFont(coords_font)

    local file_color = BlackColor
    local rank_color = WhiteColor

    for i = 0, 7 do
        local x_pos = i * SquareSize + SquareLabelXoffset
        local y_pos = i * SquareSize + SquareLabelYoffset
        if i % 2 == 0 then
            file_color = WhiteColor
            rank_color = BlackColor
        else
            file_color = BlackColor
            rank_color = WhiteColor
        end
        love.graphics.setColor(file_color)
        love.graphics.print(files[i + 1], x_pos, BoardWidth - 18)
        love.graphics.setColor(rank_color)
        love.graphics.print(ranks[i + 1], 5, y_pos)
    end
end

return game
