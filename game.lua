local game = {}

-- ratings as example
Ratings = { 1150, 1214, 1230, 1237, 1235, 1220, 1259, 1273, 1280, 1274 }

Main_menu = {
    buttons = {
        {
            text = "Next Puzzle",
            y = 0,
            height = 40,
            clicked = false,
            fnt = function()
                print("Next Puzzle btn")
            end
        },
        {
            text = "Something to select level",
            y = 50,
            height = 40,
            clicked = false,
            fnt = function()
                print("this is the settings")
            end
        },
        {
            text = "Close",
            y = 100,
            height = 40,
            clicked = false,
            fnt = function()
                print("this is close")
                love.event.quit()
            end
        }
    }
}

LevelDropdown = {
    x = MainMenu_X + 40, -- this is recalculated later
    y = 160,
    width = 150,
    height = 30,
    options = {},
    selected = "Auto",
    isOpen = false
}
table.insert(LevelDropdown.options, "Auto")
for i = 400, 2000, 100 do
    table.insert(LevelDropdown.options, i)
end


function game.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    PricesSprites = love.graphics.newImage("resources/pieces.png")
    BoardTilesSprites = love.graphics.newImage("resources/board-tiles-64x64.png")
    WhiteQuad = love.graphics.newQuad(0, 0, BoardTileSpriteSize, BoardTileSpriteSize, BoardTilesSprites:getDimensions())
    BlackQuad = love.graphics.newQuad(BoardTileSpriteSize, 0, BoardTileSpriteSize, BoardTileSpriteSize,
        BoardTilesSprites:getDimensions())
    LabelFont = love.graphics.newFont("resources/labelFont.ttf", LabelFontSize)
    MenuFont = love.graphics.newFont("resources/labelFont.ttf", MenuFontSize)
    RatingFont = love.graphics.newFont("resources/labelFont.ttf", RatingFontSize)

    BackgroundTexture = love.graphics.newImage("resources/background.png")
    BackgroundTextureWidth = BackgroundTexture:getWidth()
    BackgroundTextureHeight = BackgroundTexture:getHeight()
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
    -- love.graphics.clear(SoftGray) -- Dark gray background for contrast
    game.draw_background()
    game.draw_empty_board()
    game.draw_pieces_start_position()
    game.draw_ratings_graph(Ratings, MainMenu_X + 40, 40, MainMenu_Width - 40, 100)
    game.draw_main_menu()

    game.highlight_mouse_pointer()
    -- game.draw_selected_squares()
    -- game.draw_level_selector()
end

game.draw_background = function()
    -- Get the screen dimensions
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    -- Calculate how many times to repeat the texture horizontally and vertically
    local repeatX = math.ceil(screenWidth / BackgroundTextureWidth)
    local repeatY = math.ceil(screenHeight / BackgroundTextureHeight)

    -- Draw the repeating texture
    love.graphics.setColor({ 1, 1, 1 })
    for y = 0, repeatY - 1 do
        for x = 0, repeatX - 1 do
            love.graphics.draw(BackgroundTexture, x * BackgroundTextureWidth, y * BackgroundTextureHeight)
        end
    end
end

game.draw_main_menu = function()
    -- Draw buttons
    for i, button in ipairs(Main_menu.buttons) do
        -- Set button color (change if clicked)
        if button.clicked then
            love.graphics.setColor(0.4, 0.4, 0.8) -- Light blue when clicked
        else
            love.graphics.setColor(0.3, 0.3, 0.7) -- Dark blue when not clicked
        end
        -- Draw button rectangle
        love.graphics.rectangle("fill", MainMenu_X, MainMenu_Y + button.y, MainMenu_Width, button.height, 5, 5)

        -- record the coors of the button, to know later if its clicked
        button.x_start = MainMenu_X
        button.x_end = MainMenu_X + MainMenu_Width
        button.y_start = MainMenu_Y + button.y
        button.y_end = button.y_start + button.height

        -- Draw button text
        love.graphics.setColor(1, 1, 1) -- White text
        local textWidth = MenuFont:getWidth(button.text)
        local textHeight = MenuFont:getHeight()
        love.graphics.setFont(MenuFont)
        -- love.graphics.print(button.text, MainMenu_X + 10 + (button.width - textWidth) / 2,
        --    MainMenu_Y + button.y + (button.height - textHeight) / 2)
        love.graphics.print(button.text, MainMenu_X + (MainMenu_Width - textWidth) / 2, MainMenu_Y + button.y + 8)
    end
end

game.draw_selected_squares = function()
    -- Highlight the selected square (if not blinking or during the "on" phase of blinking)
    if SelectedSquare and not (IsBlinking and BlinkCount % 2 == 1) then
        love.graphics.setColor(SelectedSquareColor, 0.5) -- Green outline
        love.graphics.rectangle("line", SelectedSquare.x * SquareSize, SelectedSquare.y * SquareSize, SquareSize,
            SquareSize)
    end
    -- Highlight the new square (if not blinking or during the "on" phase of blinking)
    if NewSquare and not (IsBlinking and BlinkCount % 2 == 1) then
        love.graphics.setColor(SelectedSquareColor, 0.5)
        love.graphics.rectangle("line", NewSquare.x * SquareSize, NewSquare.y * SquareSize, SquareSize, SquareSize)
    end
end

game.highlight_mouse_pointer = function()
    -- Get mouse position
    local mouseX, mouseY = love.mouse.getPosition()

    -- Calculate which square the mouse is over
    local hoverX = math.floor(mouseX / SquareSize)
    local hoverY = math.floor(mouseY / SquareSize)
    -- print("hoverX:" .. hoverX)
    -- print("hoverY:" .. hoverY)
    -- print("SquareSize:" .. SquareSize)


    -- Check if the mouse is within the bounds of the chessboard
    if hoverX >= 0 and hoverX < 8 and hoverY >= 0 and hoverY < 8 then
        -- Draw a semi-transparent highlight over the square
        love.graphics.setColor(SelectedSquareColor)
        love.graphics.setLineWidth(2) -- Set the outline thickness
        love.graphics.rectangle("line", hoverX * SquareSize, hoverY * SquareSize, SquareSize, SquareSize)
    end
end

-- this function is only for testing settings
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
    for x = 0, 7 do
        y_pos = 1 * SquareSize
        love.graphics.draw(PricesSprites, BPawn, x * SquareSize, y_pos, 0, PieceScaleFactor)
    end
    for x = 0, 7 do
        y_pos = 6 * SquareSize
        love.graphics.draw(PricesSprites, WPawn, x * SquareSize, y_pos, 0, PieceScaleFactor)
    end
    love.graphics.draw(PricesSprites, BRook, 0 * SquareSize, 0 * SquareSize, 0, PieceScaleFactor)
    love.graphics.draw(PricesSprites, BRook, 7 * SquareSize, 0 * SquareSize, 0, PieceScaleFactor)
    love.graphics.draw(PricesSprites, WRook, 0 * SquareSize, 7 * SquareSize, 0, PieceScaleFactor)
    love.graphics.draw(PricesSprites, WRook, 7 * SquareSize, 7 * SquareSize, 0, PieceScaleFactor)
    love.graphics.draw(PricesSprites, BKnight, 1 * SquareSize, 0 * SquareSize, 0, PieceScaleFactor)
    love.graphics.draw(PricesSprites, BKnight, 6 * SquareSize, 0 * SquareSize, 0, PieceScaleFactor)
    love.graphics.draw(PricesSprites, WKnight, 1 * SquareSize, 7 * SquareSize, 0, PieceScaleFactor)
    love.graphics.draw(PricesSprites, WKnight, 6 * SquareSize, 7 * SquareSize, 0, PieceScaleFactor)
    love.graphics.draw(PricesSprites, BBishop, 2 * SquareSize, 0 * SquareSize, 0, PieceScaleFactor)
    love.graphics.draw(PricesSprites, BBishop, 5 * SquareSize, 0 * SquareSize, 0, PieceScaleFactor)
    love.graphics.draw(PricesSprites, WBishop, 2 * SquareSize, 7 * SquareSize, 0, PieceScaleFactor)
    love.graphics.draw(PricesSprites, WBishop, 5 * SquareSize, 7 * SquareSize, 0, PieceScaleFactor)
    love.graphics.draw(PricesSprites, BQueen, 3 * SquareSize, 0 * SquareSize, 0, PieceScaleFactor)
    love.graphics.draw(PricesSprites, WQueen, 3 * SquareSize, 7 * SquareSize, 0, PieceScaleFactor)
    love.graphics.draw(PricesSprites, BKing, 4 * SquareSize, 0 * SquareSize, 0, PieceScaleFactor)
    love.graphics.draw(PricesSprites, WKing, 4 * SquareSize, 7 * SquareSize, 0, PieceScaleFactor)
end

-- this function is only to round the intervals of the graph
function Dynamic_round(n)
    local base = 5
    if n < 5 then
        base = 5
    elseif n < 10 then
        base = 10
    else
        base = 20
    end
    return math.floor(n / base) * base
end

game.draw_ratings_graph = function(ratings, x, y, width, height)
    love.graphics.setFont(RatingFont)
    local lastRating = ratings[#ratings]
    -- Draw the Y-axis label
    love.graphics.setColor(0, 0, 0) -- White for text
    love.graphics.print("Current Rating: " .. lastRating, x, y - RatingFont:getHeight() - 5)

    local minRating = ratings[1]
    local maxRating = ratings[1]

    for i = 2, #ratings do
        if ratings[i] < minRating then
            minRating = ratings[i]
        end
        if ratings[i] > maxRating then
            maxRating = ratings[i]
        end
    end

    -- Calculate scaling factors
    local scaleX = width / (#ratings - 1)
    local scaleY = height / (maxRating - minRating)

    -- Draw the graph background
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", x, y, width, height)

    -- Calculate a dynamic guide line interval
    local range = maxRating - minRating
    local numGuides = 3
    local guideLineInterval = Dynamic_round(range / numGuides)

    -- Ensure the interval is at least 5
    if guideLineInterval < 5 then
        guideLineInterval = 5
    end

    -- Draw horizontal guide lines and labels
    love.graphics.setColor(0.5, 0.5, 0.5) -- Gray for guide lines
    for ratingLevel = Dynamic_round(minRating + guideLineInterval), maxRating, guideLineInterval do
        -- Calculate the Y position of the guide line
        local yLine = y + height - (ratingLevel - minRating) * scaleY
        love.graphics.line(x, yLine, x + width, yLine)
        love.graphics.print(ratingLevel, x - 50, yLine - 10) -- Adjust position for label
    end


    -- Draw the line graph
    for i = 2, #ratings do
        -- Calculate the positions of the current and previous points
        local x1 = x + (i - 2) * scaleX
        local y1 = y + height - (ratings[i - 1] - minRating) * scaleY
        local x2 = x + (i - 1) * scaleX
        local y2 = y + height - (ratings[i] - minRating) * scaleY

        -- Determine the line color based on whether the rating increased or decreased
        if ratings[i] > ratings[i - 1] then
            love.graphics.setColor(0, 1, 0) -- Green for increase
        elseif ratings[i] < ratings[i - 1] then
            love.graphics.setColor(1, 0, 0) -- Red for decrease
        else
            love.graphics.setColor(1, 1, 1) -- White for no change
        end
        -- Draw the line segment
        love.graphics.line(x1, y1, x2, y2)
    end
    -- Reset the color to white (optional)
    love.graphics.setColor(1, 1, 1)
end

game.draw_level_selector = function()
    LevelDropdown.x = MainMenu_X + 40
    LevelDropdown.y = 160

    -- Draw the dropdown box
    love.graphics.setColor(0.8, 0.8, 0.8) -- Light gray
    love.graphics.rectangle("fill", LevelDropdown.x, LevelDropdown.y, LevelDropdown.width, LevelDropdown.height)
    love.graphics.setColor(0, 0, 0)       -- Black
    love.graphics.rectangle("line", LevelDropdown.x, LevelDropdown.y, LevelDropdown.width, LevelDropdown.height)

    -- Draw selected text
    love.graphics.print(LevelDropdown.selected, LevelDropdown.x + 10, LevelDropdown.y + 4)

    -- Draw the dropdown options if open
    if LevelDropdown.isOpen then
        for i, option in ipairs(LevelDropdown.options) do
            local optionY = LevelDropdown.y + LevelDropdown.height * i
            love.graphics.setColor(0.9, 0.9, 0.9) -- Slightly darker gray
            love.graphics.rectangle("fill", LevelDropdown.x, optionY, LevelDropdown.width, LevelDropdown.height)
            love.graphics.setColor(0, 0, 0)       -- Black
            love.graphics.rectangle("line", LevelDropdown.x, optionY, LevelDropdown.width, LevelDropdown.height)
            love.graphics.print(option, LevelDropdown.x + 10, optionY + 4)
        end
    end
end

return game
