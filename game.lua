local game = {}

local main_menu = {
    width = 200, -- Width of the menu
    height = 300,
    buttons = {
        { text = "Puzzles",  y = 50,  width = 180, height = 40, clicked = false },
        { text = "Settings", y = 120, width = 180, height = 40, clicked = false },
        { text = "Close",    y = 190, width = 180, height = 40, clicked = false }
    }
}

function game.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    PricesSprites = love.graphics.newImage("resources/pieces.png")
    BoardTilesSprites = love.graphics.newImage("resources/board-tiles-64x64.png")

    WhiteQuad = love.graphics.newQuad(0, 0, BoardTileSpriteSize, BoardTileSpriteSize, BoardTilesSprites:getDimensions())
    BlackQuad = love.graphics.newQuad(BoardTileSpriteSize, 0, BoardTileSpriteSize, BoardTileSpriteSize,
        BoardTilesSprites:getDimensions())

    LabelFont = love.graphics.newFont("resources/labelFont.ttf", LabelFontSize)
    MenuFont = love.graphics.newFont("resources/labelFont.ttf", MenuFontSize)

    WKing = love.graphics.newQuad(0, 0, PieceSpriteSize, PieceSpriteSize, PricesSprites)
    WQueen = love.graphics.newQuad(PieceSpriteSize, 0, PieceSpriteSize, PieceSpriteSize, PricesSprites)
    WBishop = love.graphics.newQuad(2 * PieceSpriteSize, 0, PieceSpriteSize, PieceSpriteSize, PricesSprites)
    WKnight = love.graphics.newQuad(3 * PieceSpriteSize, 0, PieceSpriteSize, PieceSpriteSize, PricesSprites)
    WRook = love.graphics.newQuad(4 * PieceSpriteSize, 0, PieceSpriteSize, PieceSpriteSize, PricesSprites)
    WPawn = love.graphics.newQuad(5 * PieceSpriteSize, 0, PieceSpriteSize, PieceSpriteSize, PricesSprites)

    BKing = love.graphics.newQuad(0, PieceSpriteSize, PieceSpriteSize, PieceSpriteSize, PricesSprites)
    BQueen = love.graphics.newQuad(PieceSpriteSize, PieceSpriteSize, PieceSpriteSize, PieceSpriteSize, PricesSprites)
    BBishop = love.graphics.newQuad(2 * PieceSpriteSize, PieceSpriteSize, PieceSpriteSize, PieceSpriteSize, PricesSprites)
    BKnight = love.graphics.newQuad(3 * PieceSpriteSize, PieceSpriteSize, PieceSpriteSize, PieceSpriteSize, PricesSprites)
    BRook = love.graphics.newQuad(4 * PieceSpriteSize, PieceSpriteSize, PieceSpriteSize, PieceSpriteSize, PricesSprites)
    BPawn = love.graphics.newQuad(5 * PieceSpriteSize, PieceSpriteSize, PieceSpriteSize, PieceSpriteSize, PricesSprites)

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

    game.draw_main_menu()
end

game.draw_main_menu = function()
    -- Draw the menu background
    love.graphics.setColor(0.2, 0.2, 0.2) -- Dark gray background
    love.graphics.rectangle("fill", MainMenu_X, MainMenu_Y, main_menu.width, main_menu.height, 10, 10)

    -- Draw buttons
    for i, button in ipairs(main_menu.buttons) do
        -- Set button color (change if clicked)
        if button.clicked then
            love.graphics.setColor(0.4, 0.4, 0.8) -- Light blue when clicked
        else
            love.graphics.setColor(0.3, 0.3, 0.7) -- Dark blue when not clicked
        end

        -- Draw button rectangle
        love.graphics.rectangle("fill", MainMenu_X + 10, MainMenu_Y + button.y, button.width, button.height, 5, 5)

        -- Draw button text
        love.graphics.setColor(1, 1, 1) -- White text
        local textWidth = MenuFont:getWidth(button.text)
        local textHeight = MenuFont:getHeight()
        love.graphics.setFont(MenuFont)
        love.graphics.print(button.text, MainMenu_X + 10 + (button.width - textWidth) / 2,
            MainMenu_Y + button.y + (button.height - textHeight) / 2)
    end
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

        -- check if a menu was clicked
        for i, btn in ipairs(main_menu.buttons) do
            if x > MainMenu_X + 10 and x < MainMenu_X + 10 + btn.width and
                y > (MainMenu_Y + btn.y) and y < (MainMenu_Y + btn.y) + btn.height then
                btn.clicked = true -- Mark the button as clicked

                -- Handle button actions
                if btn.text == "Puzzles" then
                    print("Puzzles button clicked!")
                elseif btn.text == "Settings" then
                    print("Settings button clicked!")
                elseif btn.text == "Close" then
                    print("Settings button clicked!")
                    love.event.quit() -- Close the application
                end
            else
                btn.clicked = false -- Deselect other buttons
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
    local squareScale = SquareSize / BoardTileSpriteSize

    love.graphics.setColor(WhiteColor)
    love.graphics.rectangle("fill", 0, 0, BoardWidth, BoardWidth)
    love.graphics.setColor(BlackColor)
    for x = 0, 7 do
        for y = 0, 7 do
            if (x + y) % 2 == 1 then
                love.graphics.draw(BoardTilesSprites, BlackQuad, x * SquareSize, y * SquareSize, 0, squareScale,
                    squareScale)
                --love.graphics.rectangle("fill", x * SquareSize, y * SquareSize, SquareSize, SquareSize)
            else
                love.graphics.draw(BoardTilesSprites, WhiteQuad, x * SquareSize, y * SquareSize, 0, squareScale,
                    squareScale)
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
        love.graphics.draw(PricesSprites, BPawn, x * SquareSize, y_pos, 0, PieceScaleFactor)
    end

    -- draw white pawns
    for x = 0, 7 do
        y_pos = 6 * SquareSize
        love.graphics.draw(PricesSprites, WPawn, x * SquareSize, y_pos, 0, PieceScaleFactor)
    end

    -- Draw black rooks
    love.graphics.draw(PricesSprites, BRook, 0 * SquareSize, 0 * SquareSize, 0, PieceScaleFactor)
    love.graphics.draw(PricesSprites, BRook, 7 * SquareSize, 0 * SquareSize, 0, PieceScaleFactor)

    -- Draw white rooks
    love.graphics.draw(PricesSprites, WRook, 0 * SquareSize, 7 * SquareSize, 0, PieceScaleFactor)
    love.graphics.draw(PricesSprites, WRook, 7 * SquareSize, 7 * SquareSize, 0, PieceScaleFactor)

    -- Draw black knights
    love.graphics.draw(PricesSprites, BKnight, 1 * SquareSize, 0 * SquareSize, 0, PieceScaleFactor)
    love.graphics.draw(PricesSprites, BKnight, 6 * SquareSize, 0 * SquareSize, 0, PieceScaleFactor)

    -- Draw white knights
    love.graphics.draw(PricesSprites, WKnight, 1 * SquareSize, 7 * SquareSize, 0, PieceScaleFactor)
    love.graphics.draw(PricesSprites, WKnight, 6 * SquareSize, 7 * SquareSize, 0, PieceScaleFactor)

    -- Draw black bishops
    love.graphics.draw(PricesSprites, BBishop, 2 * SquareSize, 0 * SquareSize, 0, PieceScaleFactor)
    love.graphics.draw(PricesSprites, BBishop, 5 * SquareSize, 0 * SquareSize, 0, PieceScaleFactor)

    -- Draw white bishops
    love.graphics.draw(PricesSprites, WBishop, 2 * SquareSize, 7 * SquareSize, 0, PieceScaleFactor)
    love.graphics.draw(PricesSprites, WBishop, 5 * SquareSize, 7 * SquareSize, 0, PieceScaleFactor)

    -- Draw black queen
    love.graphics.draw(PricesSprites, BQueen, 3 * SquareSize, 0 * SquareSize, 0, PieceScaleFactor)

    -- Draw white queen
    love.graphics.draw(PricesSprites, WQueen, 3 * SquareSize, 7 * SquareSize, 0, PieceScaleFactor)

    -- Draw black king
    love.graphics.draw(PricesSprites, BKing, 4 * SquareSize, 0 * SquareSize, 0, PieceScaleFactor)

    -- Draw white king
    love.graphics.draw(PricesSprites, WKing, 4 * SquareSize, 7 * SquareSize, 0, PieceScaleFactor)
end

return game
