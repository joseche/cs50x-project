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

    -- Variables to track clicked squares
    SelectedSquare = nil -- Currently selected square
    NewSquare = nil      -- Newly clicked square
    BlinkTimer = 0       -- Timer for blinking
    BlinkCount = 0       -- Number of blinks completed
    IsBlinking = false   -- Whether blinking is active
end

game.draw = function()
    love.graphics.clear(SoftGray) -- Dark gray background for contrast
    game.draw_empty_board()

    -- temporarily:
    game.draw_pieces_start_position()

    game.highlight_mouse_pointer()
    game.draw_selected_squares()
end



function love.mousepressed(x, y, button)
    if button == 1 then -- Left mouse button
        -- Calculate which square was clicked
        local clickedX = math.floor(x / SquareSize)
        local clickedY = math.floor(y / SquareSize)

        -- Check if the click is within the chessboard bounds
        if clickedX >= 0 and clickedX < 8 and clickedY >= 0 and clickedY < 8 then
            if SelectedSquare == nil then
                -- No square is currently selected, so select the clicked square
                SelectedSquare = { x = clickedX, y = clickedY }
            else
                -- A square is already selected, so start blinking
                NewSquare = { x = clickedX, y = clickedY }
                IsBlinking = true
                BlinkTimer = 0
                BlinkCount = 0
            end
        end
    end
end

function love.update(dt)
    -- Handle blinking logic
    if IsBlinking then
        BlinkTimer = BlinkTimer + dt
        if BlinkTimer >= 0.25 then -- Blink every 0.25 seconds
            BlinkTimer = 0
            BlinkCount = BlinkCount + 1
            if BlinkCount >= 4 then  -- Blink twice (2 full cycles)
                SelectedSquare = nil -- Deselect both squares
                NewSquare = nil
                IsBlinking = false
                BlinkCount = 0
            end
        end
    end
end

game.draw_selected_squares = function()
    -- Highlight the selected square (if not blinking or during the "on" phase of blinking)
    if SelectedSquare and not (IsBlinking and BlinkCount % 2 == 1) then
        love.graphics.setColor(0, 1, 0) -- Green outline
        love.graphics.rectangle("line", SelectedSquare.x * SquareSize, SelectedSquare.y * SquareSize, SquareSize,
            SquareSize)
    end

    -- Highlight the new square (if not blinking or during the "on" phase of blinking)
    if NewSquare and not (IsBlinking and BlinkCount % 2 == 1) then
        love.graphics.setColor(DarkGreyColor, 0.5)
        love.graphics.rectangle("line", NewSquare.x * SquareSize, NewSquare.y * SquareSize, SquareSize, SquareSize)
    end
end


game.highlight_mouse_pointer = function()
    -- Get mouse position
    local mouseX, mouseY = love.mouse.getPosition()

    -- Calculate which square the mouse is over
    local hoverX = math.floor(mouseX / SquareSize)
    local hoverY = math.floor(mouseY / SquareSize)

    -- Check if the mouse is within the bounds of the chessboard
    if hoverX >= 0 and hoverX < 8 and hoverY >= 0 and hoverY < 8 then
        -- Draw a semi-transparent highlight over the square
        love.graphics.setColor(0, 1, 0, 0.5)
        love.graphics.setLineWidth(3) -- Set the outline thickness
        love.graphics.rectangle("line", hoverX * SquareSize, hoverY * SquareSize, SquareSize, SquareSize)
    end
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
