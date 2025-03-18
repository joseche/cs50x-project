local game = {}

Debug = true                -- to print verbose messages
Ratings = { DefaultRating } -- this will be loaded in game.load
Puzzles = {}                -- To store puzzles indexed by rating

CurrentPuzzle = {
    PuzzleId = "",
    rating = 0,
    level = 0,
    FEN = "",
    themes = "",
    moves = "",
    hints = 0,
}

PieceMoving = {
    x = 0,            -- Current x position (pixels)
    y = 0,            -- Current y position (pixels)
    origin_file = 0,  -- Origin x position (pixels)
    origin_rank = 0,  -- Origin y position (pixels)
    target_file = 0,  -- Destination x position (pixels)
    target_rank = 0,  -- Destination y position (pixels)
    isMoving = false, -- Whether the piece is currently moving
    quad = nil,
    piece = "",
}

function game.empty_board()
    return {
        { "", "", "", "", "", "", "", "", },
        { "", "", "", "", "", "", "", "", },
        { "", "", "", "", "", "", "", "", },
        { "", "", "", "", "", "", "", "", },
        { "", "", "", "", "", "", "", "", },
        { "", "", "", "", "", "", "", "", },
        { "", "", "", "", "", "", "", "", },
        { "", "", "", "", "", "", "", "", },
    }
end

CurrentBoard = game.empty_board()

Main_menu = {
    buttons = {
        {
            text = "Next Puzzle",
            y = 0,
            height = 40,
            clicked = false,
            fnt = function()
                game.load_random_puzzle()
            end
        },
        {
            text = "Hint",
            y = 50,
            height = 40,
            clicked = false,
            fnt = function()
                print("Hint")
            end
        },
        {
            text = "Close",
            y = 100,
            height = 40,
            clicked = false,
            color = { 0.8, 0.4, 0.2 },
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
    width = 100,
    height = 30,
    options = {}, -- filled in the 'for' below
    selected = "Auto",
    isOpen = false
}
table.insert(LevelDropdown.options, "Auto")
for i = 400, 2000, 100 do
    table.insert(LevelDropdown.options, i)
end

function game.debug(msg)
    if Debug then
        print(msg)
    end
end

function UserRating()
    return Ratings[#Ratings]
end

function game.rating_to_level(rating)
    return math.floor(rating / 100) * 100
end

function game.current_level()
    if LevelDropdown.selected == "Auto" then
        return game.rating_to_level(UserRating())
    else
        return LevelDropdown.selected
    end
end

function game.add_rating(new_rating)
    game.debug("adding user rating " .. new_rating)
    table.insert(Ratings, new_rating)
end

function RatingRoundDown(rating)
    return math.floor(rating / RatingRoundingFactor) * RatingRoundingFactor
end

function RatingRoundUp(rating)
    return math.ceil(rating / RatingRoundingFactor) * RatingRoundingFactor
end

function game.load()
    CalculateRelativeScreenVariables()
    love.graphics.setDefaultFilter("nearest", "nearest") -- according to the lecture this improves rendering of lines
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

    PieceQuads = {
        -- white pieces
        ['K'] = love.graphics.newQuad(0, 0, PieceSpriteSize, PieceSpriteSize, PricesSprites),
        ['Q'] = love.graphics.newQuad(PieceSpriteSize, 0, PieceSpriteSize, PieceSpriteSize, PricesSprites),
        ['B'] = love.graphics.newQuad(2 * PieceSpriteSize, 0, PieceSpriteSize, PieceSpriteSize, PricesSprites),
        ['N'] = love.graphics.newQuad(3 * PieceSpriteSize, 0, PieceSpriteSize, PieceSpriteSize, PricesSprites),
        ['R'] = love.graphics.newQuad(4 * PieceSpriteSize, 0, PieceSpriteSize, PieceSpriteSize, PricesSprites),
        ['P'] = love.graphics.newQuad(5 * PieceSpriteSize, 0, PieceSpriteSize, PieceSpriteSize, PricesSprites),

        -- black pieces
        ['k'] = love.graphics.newQuad(0, PieceSpriteSize, PieceSpriteSize, PieceSpriteSize, PricesSprites),
        ['q'] = love.graphics.newQuad(PieceSpriteSize, PieceSpriteSize, PieceSpriteSize, PieceSpriteSize, PricesSprites),
        ['b'] = love.graphics.newQuad(2 * PieceSpriteSize, PieceSpriteSize, PieceSpriteSize, PieceSpriteSize,
            PricesSprites),
        ['n'] = love.graphics.newQuad(3 * PieceSpriteSize, PieceSpriteSize, PieceSpriteSize, PieceSpriteSize,
            PricesSprites),
        ['r'] = love.graphics.newQuad(4 * PieceSpriteSize, PieceSpriteSize, PieceSpriteSize, PieceSpriteSize,
            PricesSprites),
        ['p'] = love.graphics.newQuad(5 * PieceSpriteSize, PieceSpriteSize, PieceSpriteSize, PieceSpriteSize,
            PricesSprites)
    }

    -- Variables to track clicked squares, I have to make this into a list of events happening
    SelectedSquare = nil -- Currently selected square
    NewSquare = nil      -- Newly clicked square
    BlinkTimer = 0       -- Timer for blinking
    BlinkCount = 0       -- Number of blinks completed
    IsBlinking = false   -- Whether blinking is active

    game.load_user_ratings()
    game.load_puzzles_by_rating(UserRating())
    game.load_random_puzzle()
end

function game.draw()
    game.draw_background()
    game.draw_empty_board()
    game.draw_current_board()
    game.draw_ratings_graph(Ratings, MainMenu_X + 40, 40, MainMenu_Width - 40, 100)
    game.draw_main_menu()
    game.draw_level_selector()

    -- dynamic elements
    game.highlight_mouse_pointer()
    game.draw_selected_squares()
end

function game.draw_background()
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

function game.draw_main_menu()
    -- Draw buttons
    for i, button in ipairs(Main_menu.buttons) do
        -- Set button color (change if clicked)
        if button.clicked then
            love.graphics.setColor(0.4, 0.4, 0.8) -- Light blue when clicked
        else
            if button["color"] ~= nil then
                love.graphics.setColor(button["color"])
            else
                love.graphics.setColor(0.3, 0.3, 0.7) -- Dark blue when not clicked
            end
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

function game.draw_selected_squares()
    -- Highlight the selected square (if not blinking or during the "on" phase of blinking)
    if SelectedSquare and not (IsBlinking and BlinkCount % 2 == 1) then
        love.graphics.setColor(SelectedSquareColor, 0.5) -- Green outline
        love.graphics.rectangle("line", (SelectedSquare.file - 1) * SquareSize, (8 - SelectedSquare.rank) * SquareSize,
            SquareSize,
            SquareSize)
    end
    -- Highlight the new square (if not blinking or during the "on" phase of blinking)
    if NewSquare and not (IsBlinking and BlinkCount % 2 == 1) then
        love.graphics.setColor(SelectedSquareColor, 0.5)
        love.graphics.rectangle("line", (NewSquare.file - 1) * SquareSize, (8 - NewSquare.rank) * SquareSize,
            SquareSize,
            SquareSize)
    end
end

function game.highlight_mouse_pointer()
    local mouseX, mouseY = love.mouse.getPosition()
    local squareFile = math.floor(mouseX / SquareSize)
    local squareRank = math.floor(mouseY / SquareSize)
    -- Check if the mouse is within the bounds of the chessboard
    if squareFile >= 0 and squareFile < 8 and squareRank >= 0 and squareRank < 8 then
        -- Draw a semi-transparent highlight over the square
        love.graphics.setColor(SelectedSquareColor)
        love.graphics.setLineWidth(2) -- Set the outline thickness
        love.graphics.rectangle("line", squareFile * SquareSize, squareRank * SquareSize, SquareSize, SquareSize)
    end
end

-- this function is only for testing settings
function game.draw_colors()
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

function game.draw_empty_board()
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

function game.draw_pieces_start_position()
    love.graphics.setColor(1, 1, 1)
    for x = 0, 7 do
        local y_pos = 1 * SquareSize
        love.graphics.draw(PricesSprites, PieceQuads['p'], x * SquareSize, y_pos, 0, PieceScaleFactor)
    end
    for x = 0, 7 do
        local y_pos = 6 * SquareSize
        love.graphics.draw(PricesSprites, PieceQuads['P'], x * SquareSize, y_pos, 0, PieceScaleFactor)
    end

    love.graphics.draw(PricesSprites, PieceQuads['r'], 0 * SquareSize, 0 * SquareSize, 0, PieceScaleFactor)
    love.graphics.draw(PricesSprites, PieceQuads['r'], 7 * SquareSize, 0 * SquareSize, 0, PieceScaleFactor)
    love.graphics.draw(PricesSprites, PieceQuads['R'], 0 * SquareSize, 7 * SquareSize, 0, PieceScaleFactor)
    love.graphics.draw(PricesSprites, PieceQuads['R'], 7 * SquareSize, 7 * SquareSize, 0, PieceScaleFactor)
    love.graphics.draw(PricesSprites, PieceQuads['n'], 1 * SquareSize, 0 * SquareSize, 0, PieceScaleFactor)
    love.graphics.draw(PricesSprites, PieceQuads['n'], 6 * SquareSize, 0 * SquareSize, 0, PieceScaleFactor)
    love.graphics.draw(PricesSprites, PieceQuads['N'], 1 * SquareSize, 7 * SquareSize, 0, PieceScaleFactor)
    love.graphics.draw(PricesSprites, PieceQuads['N'], 6 * SquareSize, 7 * SquareSize, 0, PieceScaleFactor)
    love.graphics.draw(PricesSprites, PieceQuads['b'], 2 * SquareSize, 0 * SquareSize, 0, PieceScaleFactor)
    love.graphics.draw(PricesSprites, PieceQuads['b'], 5 * SquareSize, 0 * SquareSize, 0, PieceScaleFactor)
    love.graphics.draw(PricesSprites, PieceQuads['B'], 2 * SquareSize, 7 * SquareSize, 0, PieceScaleFactor)
    love.graphics.draw(PricesSprites, PieceQuads['B'], 5 * SquareSize, 7 * SquareSize, 0, PieceScaleFactor)
    love.graphics.draw(PricesSprites, PieceQuads['q'], 3 * SquareSize, 0 * SquareSize, 0, PieceScaleFactor)
    love.graphics.draw(PricesSprites, PieceQuads['Q'], 3 * SquareSize, 7 * SquareSize, 0, PieceScaleFactor)
    love.graphics.draw(PricesSprites, PieceQuads['k'], 4 * SquareSize, 0 * SquareSize, 0, PieceScaleFactor)
    love.graphics.draw(PricesSprites, PieceQuads['K'], 4 * SquareSize, 7 * SquareSize, 0, PieceScaleFactor)
end

function game.draw_piece(piece_quad, file, rank)
    local f = file - 1
    local r = 8 - rank
    love.graphics.draw(PricesSprites, piece_quad, f * SquareSize, r * SquareSize, 0, PieceScaleFactor)
end

function game.draw_ratings_graph(ratings, x, y, width, height)
    love.graphics.setFont(RatingFont)
    local lastRating = ratings[#ratings]
    -- Draw the Y-axis label
    love.graphics.setColor(0, 0, 0) -- White for text
    love.graphics.print("Current Rating: " .. lastRating, x, y - RatingFont:getHeight() - 5)

    local minRating = ratings[1]
    local maxRating = ratings[1]
    for i = 2, #ratings do -- this is necessary because the supported version of lua
        -- used by love doesn't have proper min and max :|
        if ratings[i] < minRating then
            minRating = ratings[i]
        end
        if ratings[i] > maxRating then
            maxRating = ratings[i]
        end
    end

    -- Calculate scaling factors
    local scaleX = width / (#ratings - 1)
    local scaleY = height / (RatingRoundUp(maxRating) - RatingRoundDown(minRating))

    -- Draw the graph background
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", x, y, width, height)

    -- Calculate a dynamic guide line interval
    local range = maxRating - minRating
    --game.debug("Range between min and max rating: " .. range)

    local numGuides = 4
    local graphLineYInterval = math.floor(range / numGuides)
    if range < 10 then
        numGuides = 1
        graphLineYInterval = 5
    end
    --game.debug("guideline Y interval: " .. graphLineYInterval)

    -- Draw horizontal guide lines and labels
    love.graphics.setColor(0.5, 0.5, 0.5) -- Gray for guide lines
    for ratingLevel = RatingRoundDown(minRating), RatingRoundUp(maxRating), graphLineYInterval do
        -- Calculate the Y position of the guide line
        local yLine = y + height - (ratingLevel - RatingRoundDown(minRating)) * scaleY
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

function game.draw_level_selector()
    LevelDropdown.x = MainMenu_X
    LevelDropdown.y = 200

    -- Draw the dropdown box
    love.graphics.setColor(0.8, 0.8, 0.8) -- Light gray
    love.graphics.rectangle("fill", LevelDropdown.x, LevelDropdown.y, LevelDropdown.width, LevelDropdown.height)
    love.graphics.setColor(0, 0, 0)       -- Black
    love.graphics.rectangle("line", LevelDropdown.x, LevelDropdown.y, LevelDropdown.width, LevelDropdown.height)

    -- Draw selected text
    love.graphics.print("Puzzle Rating", LevelDropdown.x, LevelDropdown.y - 30)
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

function game.load_user_ratings()
    local ratings = {}
    game.debug("loading user ratings")
    -- if the file doesn't exist, create with default rating
    if not love.filesystem.getInfo(UserRatingsFile) then
        local default_data = DefaultRating
        love.filesystem.write(UserRatingsFile, default_data)
    end

    local content, err = love.filesystem.read(UserRatingsFile)
    if not content then
        error("Could not read user ratings file: " .. UserRatingsFile .. ", error: " .. err)
    end

    for rating in content:gmatch("%d+") do
        table.insert(ratings, tonumber(rating))
    end
    Ratings = ratings
end

function game.write_user_ratings()
    game.debug("saving user ratings")
    local data = table.concat(Ratings, ", ")
    love.filesystem.write(UserRatingsFile, data)
end

function game.load_puzzles_by_rating(rating)
    local level = math.floor(rating / 100) * 100

    -- Check if puzzles for this rating are already loaded
    if Puzzles[level] then
        return Puzzles[level]
    end
    game.debug("loading level " .. level .. " for rating: " .. rating)

    -- Load puzzles from file if not already in memory
    local filename = "lichess-db/level_" .. level .. ".csv"
    local file = love.filesystem.read(filename)

    if file then
        local puzzleList = {}
        for line in file:gmatch("[^\r\n]+") do
            table.insert(puzzleList, line)
        end
        Puzzles[level] = puzzleList -- Store in memory
        game.debug("loaded " .. #puzzleList .. " puzzles in memory")
        return puzzleList
    else
        print("Failed to load " .. filename)
        return nil
    end
end

function Split(str, delimiter)
    local result = {}
    local pattern = string.format("([^%s]+)", delimiter)
    for word in string.gmatch(str, pattern) do
        table.insert(result, word)
    end
    return result
end

function Pretty_print(table, indent)
    indent = indent or 0                    -- Default indentation level
    local spaces = string.rep("  ", indent) -- Create indentation spaces

    for key, value in pairs(table) do
        if type(value) == "table" then
            -- If the value is a table, recursively pretty-print it
            print(spaces .. tostring(key) .. ":")
            Pretty_print(value, indent + 1) -- Increase indentation for nested tables
        else
            -- Otherwise, print the key and value
            print(spaces .. tostring(key) .. ": " .. tostring(value))
        end
    end
end

function game.load_random_puzzle()
    game.debug("choosing a random puzzle")
    local level = game.current_level()
    local options = game.load_puzzles_by_rating(level)
    if options then
        local randomIndex = math.random(#options)
        local randomPuzzle = options[randomIndex]
        game.debug("selected random index: " .. randomIndex)
        local values = Split(randomPuzzle, ',')
        CurrentPuzzle.PuzzleId = values[1]
        CurrentPuzzle.FEN = values[2]
        CurrentPuzzle.moves = values[3]
        CurrentPuzzle.rating = values[4]
        CurrentPuzzle.themes = values[6]
        CurrentPuzzle.level = level
        Pretty_print(CurrentPuzzle)
        game.load_FEN_to_board(CurrentPuzzle.FEN)
    else
        print("error loading puzzles for level: " .. level)
    end
end

function game.load_FEN_to_board(fen)
    game.debug("Loading FEN: " .. fen)
    CurrentBoard = game.empty_board()
    local rank = 8
    local file_index = 1

    local space_pos = fen:find(" ")
    local board_fen = fen:sub(1, space_pos - 1)

    for i = 1, #board_fen do
        local char = board_fen:sub(i, i)
        if char == "/" then
            rank = rank - 1
            file_index = 1
        elseif char:match("%d") then
            file_index = file_index + tonumber(char)
        elseif PieceQuads[char] then
            print("file: " .. file_index .. ", rank: " .. rank)
            CurrentBoard[file_index][rank] = char
            file_index = file_index + 1
        end
    end
    -- Pretty_print(CurrentBoard)
end

function game.draw_current_board()
    for rank = 1, 8 do
        for file = 1, 8 do
            if CurrentBoard[file][rank] ~= "" then
                game.draw_piece(PieceQuads[CurrentBoard[file][rank]], file, rank)
            end
        end
    end
    if PieceMoving.isMoving then
        game.debug("drawing moving piece")
        love.graphics.draw(PricesSprites, PieceMoving.quad, PieceMoving.x, PieceMoving.y, 0, PieceScaleFactor)
    end
end

function game.quit()
    game.write_user_ratings()
end

return game
