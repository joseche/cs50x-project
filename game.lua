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
    --draw board
    love.graphics.setColor(0.95, 0.75, 0.6)
    love.graphics.rectangle("fill", 0, 0, BoardWidth, BoardWidth)
    love.graphics.setColor(0.875, 0.6, 0.5)
    for x = 0, 7 do
        for y = 0, 7 do
            if (x + y) % 2 == 1 then
                love.graphics.rectangle("fill", x * SquareSize, y * SquareSize, SquareSize, SquareSize)
            end
        end
    end
    -- draw pieces while testing
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(Sprites, WKing, 0, 0, 0, PieceScaleFactor)
    love.graphics.draw(Sprites, WQueen, SquareSize, 0, 0, PieceScaleFactor)
    love.graphics.draw(Sprites, WBishop, 2 * SquareSize, 0, 0, PieceScaleFactor)

    love.graphics.draw(Sprites, BKing, 0, SquareSize, 0, PieceScaleFactor)
    love.graphics.draw(Sprites, BQueen, SquareSize, SquareSize, 0, PieceScaleFactor)
    love.graphics.draw(Sprites, BBishop, 2 * SquareSize, SquareSize, 0, PieceScaleFactor)
end

return game
