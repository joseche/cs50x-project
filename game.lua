dofile("globals.lua")
local settings = require("settings")
local utils = require("utils")

local game = {}

Debug = true                -- to print verbose messages
Ratings = { DefaultRating } -- this variable is loaded from the user file
Puzzles = {}                -- indexed by level
ResolvedPuzzles = {}        -- for not repeating the same puzzles

-- Variables to track clicked squares, I have to make this into a list of events happening
SelectedSquare = nil -- Currently selected square
NewSquare = nil      -- Newly clicked square
BlinkTimer = 0       -- Timer for blinking
BlinkCount = 0       -- Number of blinks completed
IsBlinking = false   -- Whether blinking is active

CurrentPuzzle = {
    PuzzleId = "",
    rating = 0,
    level = 0,
    FEN = "",
    themes = "",
    moves = "",
    last_move = "",
    hints = 0,
    errors = 0,
    rating_change = 0,
    last_hint = ""
}


PieceMoving = {
    x = 0,            -- Current x position (pixels)
    y = 0,            -- Current y position (pixels)
    origin_file = 0,  -- Origin x position (pixels)
    origin_rank = 0,  -- Origin y position (pixels)
    target_file = 0,  -- Destination x position (pixels)
    target_rank = 0,  -- Destination y position (pixels)
    isMoving = false, -- Whether the piece is currently moving
    quad = nil,       --
    piece = "",
}

ShowSuccessTimer = 0
WhitesPlay = true

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
                local n_moves = #CurrentPuzzle.moves
                -- we can not have more hints than moves
                local hint_index = CurrentPuzzle.move_index
                if hint_index <= n_moves and (CurrentPuzzle.hints * 2 < hint_index) then
                    CurrentPuzzle.hints = CurrentPuzzle.hints + 1
                    local move = CurrentPuzzle.moves[hint_index]
                    SelectedSquare = game.move_to_square(move)
                end
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
    height = 27,
    options = {}, -- filled in the 'for' below
    selected = "Auto",
    isOpen = false
}
table.insert(LevelDropdown.options, "Auto")
for i = 600, 2000, 100 do
    table.insert(LevelDropdown.options, i)
end

function game.debug(msg)
    if Debug then
        print(msg)
    end
end

function game.user_rating()
    if #Ratings == 0 then
        table.insert(Ratings, DefaultRating)
    end
    return Ratings[#Ratings]
end

function game.rating_to_level(rating)
    return math.floor(rating / 100) * 100
end

function game.current_level()
    if LevelDropdown.selected == "Auto" then
        return game.rating_to_level(game.user_rating())
    else
        return LevelDropdown.selected
    end
end

function game.add_rating(new_rating)
    game.debug("adding user rating " .. new_rating)
    table.insert(Ratings, new_rating)
end

function game.add_resolved_puzzle(puzzle_id)
    game.debug("adding resolved puzzle " .. puzzle_id)
    table.insert(ResolvedPuzzles, puzzle_id)
end

function game.update_rating()
    game.debug("Update rating: ")
    local user_rating = game.user_rating()
    local puzzle_rating = CurrentPuzzle.rating
    local K_adjust_factor = 40 - (math.abs(puzzle_rating - user_rating) / 50)
    local Expected_prob_solving = 1 / (1 + 10 ^ ((puzzle_rating - user_rating) / 400))
    local S = (CurrentPuzzle.errors > 0 and 0) or 1
    local rating_change = math.floor(K_adjust_factor * (S - Expected_prob_solving))

    -- if the user got at least one hint, reduce the positive change
    -- it will be also reasonable not to increase?
    if S == 1 and CurrentPuzzle.hints > 0 then
        rating_change = math.floor(rating_change / (CurrentPuzzle.hints + 1))
    end

    CurrentPuzzle.rating_change = rating_change
    game.debug("User rating: " .. user_rating)
    game.debug("Puzzle rating: " .. puzzle_rating)
    game.debug("K: " .. K_adjust_factor)
    game.debug("Expected_prob_solving: " .. Expected_prob_solving)
    game.debug("S: " .. S)
    game.debug("Hints used: " .. tostring(CurrentPuzzle.hints))
    game.debug("Rating change: " .. rating_change)
    game.add_rating(math.floor(game.user_rating() + rating_change))
end

local PiecesSprites, BoardTilesSprites, WhiteQuad, BlackQuad, LabelFont, MenuFont, RatingFont, RatingPopUpFont,
BackgroundTexture, BackgroundTextureWidth, BackgroundTextureHeight,
OnSound, ErrorSound, CorrectSound, NewPuzzleSound, ComputerMoveSound,
PieceQuads, WhoseTurnFont

function game.load()
    settings.update_relative_vars()
    love.graphics.setDefaultFilter("nearest", "nearest") -- according to the lecture this improves rendering of lines
    PiecesSprites = love.graphics.newImage("resources/pieces.png")
    BoardTilesSprites = love.graphics.newImage("resources/board-tiles-64x64.png")
    WhiteQuad = love.graphics.newQuad(0, 0,
        BoardTileSpriteSize,
        BoardTileSpriteSize, BoardTilesSprites:getDimensions())
    BlackQuad = love.graphics.newQuad(BoardTileSpriteSize, 0,
        BoardTileSpriteSize, BoardTileSpriteSize,
        BoardTilesSprites:getDimensions())
    LabelFont = love.graphics.newFont("resources/labelFont.ttf", LabelFontSize)
    MenuFont = love.graphics.newFont("resources/labelFont.ttf", MenuFontSize)
    RatingFont = love.graphics.newFont("resources/labelFont.ttf", RatingFontSize)
    RatingPopUpFont = love.graphics.newFont("resources/labelFont.ttf", RatingPopUpFontSize)
    WhoseTurnFont = love.graphics.newFont("resources/labelFont.ttf", LabelFontSize * 2)

    BackgroundTexture = love.graphics.newImage("resources/background.png")
    BackgroundTextureWidth = BackgroundTexture:getWidth()
    BackgroundTextureHeight = BackgroundTexture:getHeight()

    OnSound = love.audio.newSource("resources/on.wav", "static")
    ErrorSound = love.audio.newSource("resources/error.ogg", "static")
    CorrectSound = love.audio.newSource("resources/successful.mp3", "static")
    NewPuzzleSound = love.audio.newSource("resources/new_puzzle.wav", "static")
    ComputerMoveSound = love.audio.newSource("resources/computer_move.wav", "static")

    local P = PieceSpriteSize -- makes lines more readable

    PieceQuads = {
        -- white pieces
        ['K'] = love.graphics.newQuad(0 * P, 0, P, P, PiecesSprites),
        ['Q'] = love.graphics.newQuad(1 * P, 0, P, P, PiecesSprites),
        ['B'] = love.graphics.newQuad(2 * P, 0, P, P, PiecesSprites),
        ['N'] = love.graphics.newQuad(3 * P, 0, P, P, PiecesSprites),
        ['R'] = love.graphics.newQuad(4 * P, 0, P, P, PiecesSprites),
        ['P'] = love.graphics.newQuad(5 * P, 0, P, P, PiecesSprites),

        -- black pieces
        ['k'] = love.graphics.newQuad(0 * P, P, P, P, PiecesSprites),
        ['q'] = love.graphics.newQuad(1 * P, P, P, P, PiecesSprites),
        ['b'] = love.graphics.newQuad(2 * P, P, P, P, PiecesSprites),
        ['n'] = love.graphics.newQuad(3 * P, P, P, P, PiecesSprites),
        ['r'] = love.graphics.newQuad(4 * P, P, P, P, PiecesSprites),
        ['p'] = love.graphics.newQuad(5 * P, P, P, P, PiecesSprites)
    }

    game.load_user_ratings()
    game.load_resolved_puzzles()

    local user_rating = game.user_rating()
    game.debug("user rating: " .. tostring(user_rating))
    if user_rating == nil then
        game.debug("warning: user rating is nil")
        game.load_puzzles_by_rating(DefaultRating)
    else
        game.load_puzzles_by_rating(user_rating)
    end

    game.load_random_puzzle()
end

function game.draw()
    game.draw_background()
    game.draw_empty_board()
    game.draw_current_board()
    game.draw_ratings_graph(Ratings, MainMenu_X + 40, 40, MainMenu_Width - 40, 100)
    game.draw_main_menu()

    -- dynamic elements
    game.highlight_mouse_pointer()
    game.draw_puzzle_information()

    game.draw_selected_squares()
    game.draw_success_symbol()
    game.draw_level_selector()
end

function game.valid_piece_turn(piece)
    if piece == "" then
        return false
    end
    local is_black = piece:match("[kqbnrp]") ~= nil
    local black_turn = not WhitesPlay
    if is_black and black_turn then
        return true
    end
    if not is_black and WhitesPlay then
        return true
    end
    return false
end

function game.new_of_same_color_selected(piece)
    if piece == "" then
        return false
    end
    local is_black = piece:match("[kqbnrp]") ~= nil
    local black_turn = not WhitesPlay
    if black_turn and is_black then
        return true
    elseif not black_turn and not is_black then
        return true
    end
    return false
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
    for _, button in ipairs(Main_menu.buttons) do
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
        love.graphics.rectangle("fill",
            MainMenu_X, MainMenu_Y + button.y, MainMenu_Width,
            button.height, 5, 5)

        -- record the coors of the button, to know later if its clicked
        button.x_start = MainMenu_X
        button.x_end = MainMenu_X + MainMenu_Width
        button.y_start = MainMenu_Y + button.y
        button.y_end = button.y_start + button.height

        -- Draw button text
        love.graphics.setColor(1, 1, 1) -- White text
        local textWidth = MenuFont:getWidth(button.text)
        -- local textHeight = MenuFont:getHeight()
        love.graphics.setFont(MenuFont)
        -- love.graphics.print(button.text, MainMenu_X + 10 + (button.width - textWidth) / 2,
        --    MainMenu_Y + button.y + (button.height - textHeight) / 2)
        love.graphics.print(button.text, MainMenu_X + (MainMenu_Width - textWidth) / 2,
            MainMenu_Y + button.y + 8)
    end
end

function game.draw_selected_squares()
    -- Highlight the selected square (if not blinking or during the "on" phase of blinking)
    love.graphics.setBlendMode("add")    -- normal
    love.graphics.setColor(0, 1, 0, 0.2) -- Green outline
    local S = SquareSize
    if SelectedSquare and not (IsBlinking and BlinkCount % 2 == 1) then
        love.graphics.rectangle("fill", (SelectedSquare.file - 1) * S, (8 - SelectedSquare.rank) * S, S, S)
    end
    -- Highlight the new square (if not blinking or during the "on" phase of blinking)
    if NewSquare and not (IsBlinking and BlinkCount % 2 == 1) then
        love.graphics.rectangle("fill", (NewSquare.file - 1) * S, (8 - NewSquare.rank) * S, S, S)
    end
    love.graphics.setBlendMode("alpha") -- normal
end

function game.highlight_mouse_pointer()
    local mouseX, mouseY = love.mouse.getPosition()
    local S = SquareSize
    local squareFile = math.floor(mouseX / S)
    local squareRank = math.floor(mouseY / S)
    -- Check if the mouse is within the bounds of the chessboard
    if squareFile >= 0 and squareFile < 8 and squareRank >= 0 and squareRank < 8 then
        -- Draw a semi-transparent highlight over the square
        love.graphics.setColor(SelectedSquareColor)
        love.graphics.setLineWidth(2) -- Set the outline thickness
        love.graphics.rectangle("line", squareFile * S, squareRank * S, S, S)
    end
end

function game.draw_empty_board()
    local squareScale = SquareSize / BoardTileSpriteSize
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("fill", 0, 0, BoardWidth, BoardWidth)
    local S = SquareSize
    for x = 0, 7 do
        for y = 0, 7 do
            if (x + y) % 2 == 1 then
                love.graphics.draw(BoardTilesSprites, BlackQuad, x * S, y * S, 0, squareScale,
                    squareScale)
            else
                love.graphics.draw(BoardTilesSprites, WhiteQuad, x * S, y * S, 0, squareScale,
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
        local x_pos = i * S
        local y_pos = i * S
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
        love.graphics.print(files[i + 1], x_pos + FileLabelOffsetX,
            BoardHeight - FileLabelOffsetY)
    end
end

function game.draw_pieces_start_position()
    love.graphics.setColor(1, 1, 1)
    local S = SquareSize
    local F = PieceScaleFactor
    for x = 0, 7 do
        local y_pos = 1 * S
        love.graphics.draw(PiecesSprites, PieceQuads['p'], x * S, y_pos, 0, F)
    end
    for x = 0, 7 do
        local y_pos = 6 * S
        love.graphics.draw(PiecesSprites, PieceQuads['P'], x * S, y_pos, 0, F)
    end

    love.graphics.draw(PiecesSprites, PieceQuads['r'], 0 * S, 0 * S, 0, F)
    love.graphics.draw(PiecesSprites, PieceQuads['r'], 7 * S, 0 * S, 0, F)
    love.graphics.draw(PiecesSprites, PieceQuads['R'], 0 * S, 7 * S, 0, F)
    love.graphics.draw(PiecesSprites, PieceQuads['R'], 7 * S, 7 * S, 0, F)
    love.graphics.draw(PiecesSprites, PieceQuads['n'], 1 * S, 0 * S, 0, F)
    love.graphics.draw(PiecesSprites, PieceQuads['n'], 6 * S, 0 * S, 0, F)
    love.graphics.draw(PiecesSprites, PieceQuads['N'], 1 * S, 7 * S, 0, F)
    love.graphics.draw(PiecesSprites, PieceQuads['N'], 6 * S, 7 * S, 0, F)
    love.graphics.draw(PiecesSprites, PieceQuads['b'], 2 * S, 0 * S, 0, F)
    love.graphics.draw(PiecesSprites, PieceQuads['b'], 5 * S, 0 * S, 0, F)
    love.graphics.draw(PiecesSprites, PieceQuads['B'], 2 * S, 7 * S, 0, F)
    love.graphics.draw(PiecesSprites, PieceQuads['B'], 5 * S, 7 * S, 0, F)
    love.graphics.draw(PiecesSprites, PieceQuads['q'], 3 * S, 0 * S, 0, F)
    love.graphics.draw(PiecesSprites, PieceQuads['Q'], 3 * S, 7 * S, 0, F)
    love.graphics.draw(PiecesSprites, PieceQuads['k'], 4 * S, 0 * S, 0, F)
    love.graphics.draw(PiecesSprites, PieceQuads['K'], 4 * S, 7 * S, 0, F)
end

function game.draw_piece(piece_quad, file, rank)
    local f = file - 1
    local r = 8 - rank
    local S = SquareSize
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(PiecesSprites, piece_quad, f * S, r * S, 0, PieceScaleFactor)
end

function game.draw_ratings_graph(ratings, x, y, width, height)
    love.graphics.setFont(RatingFont)

    if #ratings > 20 then
        ratings = utils.get_last_n_items(ratings, 20) -- only graph the last 20
    end

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
    local scaleY = height / (utils.rating_round_up(maxRating) - utils.rating_round_down(minRating))

    -- Draw the graph background
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", x, y, width, height)

    -- Calculate a dynamic guide line interval
    local range = maxRating - minRating
    --game.debug("Range between min and max rating: " .. range)

    -- local numGuides = 4
    local graphLineYInterval = math.floor(range / 4)
    if range < 10 then
        -- numGuides = 1
        graphLineYInterval = 5
    end
    --game.debug("guideline Y interval: " .. graphLineYInterval)

    -- Draw horizontal guide lines and labels
    love.graphics.setColor(0.5, 0.5, 0.5) -- Gray for guide lines
    for ratingLevel = utils.rating_round_down(minRating), utils.rating_round_up(maxRating), graphLineYInterval do
        -- Calculate the Y position of the guide line
        local yLine = y + height - (ratingLevel - utils.rating_round_down(minRating)) * scaleY
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
    love.graphics.setFont(RatingFont)

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

function game.draw_puzzle_information()
    local reference_x = MainMenu_X
    local reference_y = 270
    love.graphics.setColor(0, 0, 0) -- Black
    love.graphics.setFont(WhoseTurnFont)
    if WhitesPlay then
        love.graphics.print("White plays", reference_x, reference_y)
        --game.draw_piece(PieceQuads["P"], 10, 4)
    else
        love.graphics.print("Black plays", reference_x, reference_y)
        --game.draw_piece(PieceQuads["p"], 10, 4)
    end
    reference_y = reference_y + 20
    love.graphics.setFont(LabelFont)
    love.graphics.setColor(0, 0, 0) -- Black
    if #CurrentPuzzle.themes > 1 then
        love.graphics.print("Theme: " .. CurrentPuzzle.themes[1], reference_x, reference_y + 30)
    end
    love.graphics.print("Level: " .. tostring(CurrentPuzzle.level), reference_x, reference_y + 60)
    love.graphics.print("Last move: " .. CurrentPuzzle.last_move, reference_x, reference_y + 90)
    if CurrentPuzzle.hints > 0 then
        for i = 1, CurrentPuzzle.hints do
            love.graphics.print("Hint " .. tostring(i) .. ": " .. CurrentPuzzle.moves[i * 2], reference_x,
                reference_y + 90 + (i * 30))
            CurrentPuzzle.last_hint = CurrentPuzzle.moves[i * 2]
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

function game.load_resolved_puzzles()
    local resolved_puzzles = {}
    game.debug("loading resolved puzzles")
    -- if the file doesn't exist, create with default rating
    if not love.filesystem.getInfo(ResolvedPuzzlesFile) then
        love.filesystem.write(ResolvedPuzzlesFile, "")
    end

    local content, err = love.filesystem.read(ResolvedPuzzlesFile)
    if content then
        for puzzleId in content:gmatch("%S+") do
            table.insert(resolved_puzzles, puzzleId)
            game.debug("Puzzle ID: " .. puzzleId)
        end
    else
        error("Could not read resolved puzzles file: " .. ResolvedPuzzlesFile .. ", error: " .. err)
    end
    ResolvedPuzzles = resolved_puzzles
end

function game.write_user_ratings()
    game.debug("saving user ratings")
    local data = table.concat(Ratings, ", ")
    love.filesystem.write(UserRatingsFile, data)
end

function game.write_resolved_puzzles()
    game.debug("saving resolved puzzles")
    local data = table.concat(ResolvedPuzzles, " ")
    love.filesystem.write(ResolvedPuzzlesFile, data)
end

function game.load_puzzles_by_rating(rating)
    game.debug("loading rating: " .. tostring(rating))
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

function game.start_move(move, duration)
    print("Starting move " .. move)
    local S = SquareSize
    CurrentPuzzle.last_move = move
    PieceMoving.isMoving = true
    PieceMoving.origin_file = string.byte(move:sub(1, 1)) - string.byte('a') + 1
    PieceMoving.origin_rank = tonumber(move:sub(2, 2))
    PieceMoving.target_file = string.byte(move:sub(3, 3)) - string.byte('a') + 1
    PieceMoving.target_rank = tonumber(move:sub(4, 4))
    PieceMoving.piece = CurrentBoard[PieceMoving.origin_file][PieceMoving.origin_rank]

    -- if a pawn reaches the opposite rank, just promote to queen
    -- auto-queen ! :)
    if PieceMoving.target_rank == 8 and PieceMoving.piece == "P" then
        PieceMoving.piece = "Q"
    elseif PieceMoving.target_rank == 1 and PieceMoving.piece == "p" then
        PieceMoving.piece = "q"
    end

    PieceMoving.quad = PieceQuads[PieceMoving.piece]

    CurrentBoard[PieceMoving.target_file][PieceMoving.target_rank] = ""
    CurrentBoard[PieceMoving.origin_file][PieceMoving.origin_rank] = ""
    PieceMoving.x = (PieceMoving.origin_file - 1) * S
    PieceMoving.y = (8 - PieceMoving.origin_rank) * S
    PieceMoving.targetX = (PieceMoving.target_file - 1) * S
    PieceMoving.targetY = (8 - PieceMoving.target_rank) * S
    PieceMoving.duration = duration
    PieceMoving.elapsed = 0
    WhitesPlay = not WhitesPlay

    SelectedSquare = { file = PieceMoving.origin_file, rank = PieceMoving.origin_rank }
    NewSquare = { file = PieceMoving.target_file, rank = PieceMoving.target_rank }
    IsBlinking = true
end

function game.puzzle_id_in_resolved_puzzles(puzzle_id)
    game.debug("checking puzzle id: " .. puzzle_id)
    for _, v in ipairs(ResolvedPuzzles) do
        if v == puzzle_id then
            game.debug("Puzzle ID: " .. puzzle_id .. " already resolved")
            return true
        end
    end
    return false
end

function game.load_random_puzzle()
    game.debug("choosing a random puzzle")
    local level = game.current_level()
    game.debug("game current level: " .. level)
    local options = game.load_puzzles_by_rating(level)
    if options then
        local randomIndex = math.random(#options)
        local randomPuzzle = options[randomIndex]
        local values = utils.split(randomPuzzle, ',')


        while game.puzzle_id_in_resolved_puzzles(values[1]) do
            randomIndex = math.random(#options)
            randomPuzzle = options[randomIndex]
            values = utils.split(randomPuzzle, ',')
        end

        game.debug("selected random index: " .. randomIndex)
        CurrentPuzzle.PuzzleId = values[1]
        CurrentPuzzle.FEN = values[2]
        CurrentPuzzle.moves = utils.split(values[3], " ")
        CurrentPuzzle.rating = values[4]
        CurrentPuzzle.themes = utils.split(values[6], " ")
        CurrentPuzzle.level = level
        CurrentPuzzle.move_index = 2
        CurrentPuzzle.UserTurn = true
        CurrentPuzzle.hints = 0
        CurrentPuzzle.errors = 0
        CurrentPuzzle.last_hint = ""
        utils.pretty_print(CurrentPuzzle)
        game.load_FEN_to_board(CurrentPuzzle.FEN)
        NewPuzzleSound:play()
        -- read the first move, and start moving the piece
        local move = CurrentPuzzle.moves[1]
        game.start_move(move, 4)
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
            -- print("file: " .. file_index .. ", rank: " .. rank)
            CurrentBoard[file_index][rank] = char
            file_index = file_index + 1
        end
    end
    WhitesPlay = fen:find(" w ") ~= nil
    game.debug("White's turn: " .. tostring(WhitesPlay))
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
        if math.random() > 0.97 then -- this is just to reduce the number of prints
            game.debug("drawing moving piece at (" .. PieceMoving.x .. "," .. PieceMoving.y .. ")")
        end
        love.graphics.draw(PiecesSprites, PieceMoving.quad, PieceMoving.x, PieceMoving.y, 0, PieceScaleFactor)
    end
end

function game.move_to_square(move)
    local file = string.byte(move:sub(1, 1)) - string.byte('a') + 1
    local rank = tonumber(move:sub(2, 2))
    return { file = file, rank = rank }
end

function game.squares_to_move(initial_square, final_square)
    -- transform the selected squares into UCI format
    local files = { 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h' }
    local origin_square = files[initial_square.file] .. initial_square.rank
    local target_square = files[final_square.file] .. final_square.rank
    local user_move = origin_square .. target_square
    return user_move
end

function game.is_expected_move(selected_square, new_square, expected_move)
    local user_move = game.squares_to_move(selected_square, new_square)
    game.debug("user move: " .. user_move)
    game.debug("expected move: " .. expected_move)
    return string.sub(user_move, 1, 4) == string.sub(expected_move, 1, 4)
end

function game.draw_success_symbol()
    -- if ShowSuccessTimer > 0 and CurrentPuzzle.errors < 1 then
    local sw, sh = BoardWidth, BoardHeight
    love.graphics.setFont(RatingPopUpFont)

    -- local iw, ih = SuccessImage:getDimensions()
    -- love.graphics.draw(SuccessImage, (sw - iw) / 2, (sh - ih) / 2)
    local rating_change_popup
    if CurrentPuzzle.rating_change > 0 then
        rating_change_popup = "+" .. tostring(CurrentPuzzle.rating_change)
        love.graphics.setColor(0, 1, 0, ShowSuccessTimer / 2)
    else
        rating_change_popup = tostring(CurrentPuzzle.rating_change)
        love.graphics.setColor(1, 0, 0, ShowSuccessTimer / 2)
    end
    local textWidth = RatingPopUpFont:getWidth(rating_change_popup)
    local textHeight = RatingPopUpFont:getHeight()
    local x = (sw - textWidth) / 2
    local y = (sh - textHeight) / 2

    love.graphics.print(rating_change_popup, x, y)
    love.graphics.setColor(1, 1, 1, 1) -- reset color
    -- end
end

function game.update_blinking(dt)
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

function game.update_piece_moving(dt)
    if PieceMoving.isMoving then
        -- Move the piece
        if PieceMoving.elapsed < PieceMoving.duration then
            PieceMoving.elapsed = PieceMoving.elapsed + dt
            local t = PieceMoving.elapsed / PieceMoving.duration
            if t > 1 then t = 1 end -- Clamp t to 1
            PieceMoving.x = PieceMoving.x + (PieceMoving.targetX - PieceMoving.x) * t
            PieceMoving.y = PieceMoving.y + (PieceMoving.targetY - PieceMoving.y) * t
        else
            -- Stop moving when close enough to the target
            PieceMoving.x, PieceMoving.y = PieceMoving.targetX, PieceMoving.targetY
            PieceMoving.isMoving = false
            CurrentBoard[PieceMoving.target_file][PieceMoving.target_rank] = PieceMoving.piece

            if type(PieceMoving.next_func) == "function" then
                PieceMoving.next_func()
            end
        end
    end
end

function game.board_clicked(file, rank)
    game.debug("file, rank: " .. tostring(file) .. "," .. tostring(rank))
    local selected_piece = CurrentBoard[file][rank]
    if SelectedSquare == nil then
        if not game.valid_piece_turn(selected_piece) then
            ErrorSound:play()
            return -- don't select pieces that are not playing / corresponding turn
        end

        print("current board position: " .. selected_piece .. ", file:" .. file .. ",rank:" .. rank)
        -- No square is currently selected, so select the clicked square if there is a piece there
        if selected_piece and selected_piece ~= "" then
            SelectedSquare = { file = file, rank = rank }
            PieceMoving.quad = PieceQuads[selected_piece]
            PieceMoving.piece = selected_piece
            game.debug("Selected Square:")
            utils.pretty_print(SelectedSquare)
        end
    elseif SelectedSquare ~= nil and file == SelectedSquare.file and rank == SelectedSquare.rank then
        game.debug("same square selected, deselecting it")
        SelectedSquare = nil
    elseif game.new_of_same_color_selected(selected_piece) then -- one piece was selected, but another of the same color
        -- was selected, select the new one
        SelectedSquare = { file = file, rank = rank }
        PieceMoving.quad = PieceQuads[selected_piece]
        PieceMoving.piece = selected_piece
        game.debug("Selected Square:")
        utils.pretty_print(SelectedSquare)
    else
        -- A square is already selected, so start blinking
        -- it doesn't matter if there is no piece in the new square
        NewSquare = { file = file, rank = rank }
        IsBlinking = true
        BlinkTimer = 0
        BlinkCount = 0

        -- check if the move is correct
        if game.is_expected_move(SelectedSquare, NewSquare, CurrentPuzzle.moves[CurrentPuzzle.move_index]) then
            CurrentPuzzle.move_index = CurrentPuzzle.move_index + 1
            if CurrentPuzzle.move_index > #CurrentPuzzle.moves then
                -- the user solved all the moves in the puzzle
                CorrectSound:play()
                ShowSuccessTimer = 2
                game.add_resolved_puzzle(CurrentPuzzle.PuzzleId)
                game.update_rating()
            else
                OnSound:play()
                print("user clicked the correct move!")
                PieceMoving.next_func = function()
                    game.start_move(CurrentPuzzle.moves[CurrentPuzzle.move_index], 1)
                    CurrentPuzzle.move_index = CurrentPuzzle.move_index + 1
                    PieceMoving.next_func = nil
                    ComputerMoveSound:play()
                end
            end

            local move = game.squares_to_move(SelectedSquare, NewSquare)
            game.start_move(move, 2)
        else
            -- user selected the wrong move, play error sound(or something!)
            CurrentPuzzle.errors = CurrentPuzzle.errors + 1
            ErrorSound:play()
        end
    end
end

function game.check_level_selector_clicked(x, y)
    -- check if a menu was clicked
    if LevelDropdown.isOpen == false then -- if the dropdown is open, button should not work
        for _, btn in ipairs(Main_menu.buttons) do
            if x > btn.x_start and x < btn.x_end and y > btn.y_start and y < btn.y_end then
                btn.clicked = true -- Mark the button as clicked
                btn.fnt()
            else
                btn.clicked = false -- Deselect other buttons
            end
        end
    end

    -- check if the level selector was clicked
    if x > LevelDropdown.x and x < LevelDropdown.x + LevelDropdown.width and
        y > LevelDropdown.y and y < LevelDropdown.y + LevelDropdown.height then
        LevelDropdown.isOpen = not LevelDropdown.isOpen
    elseif LevelDropdown.isOpen then
        -- Check if an option is clicked
        local optionSelected = false
        for i, option in ipairs(LevelDropdown.options) do
            local optionY = LevelDropdown.y + LevelDropdown.height * i
            if x > LevelDropdown.x and x < LevelDropdown.x + LevelDropdown.width and
                y > optionY and y < optionY + LevelDropdown.height then
                print("Puzzle Rating selected: " .. option)
                LevelDropdown.selected = option
                LevelDropdown.isOpen = false
                optionSelected = true
                if option == "Auto" then
                    game.load_puzzles_by_rating(game.user_rating())
                else
                    game.load_puzzles_by_rating(option)
                end
                break
            end
        end
        if optionSelected == false then
            LevelDropdown.isOpen = false
        end
    else
        LevelDropdown.isOpen = false
    end
end

function game.update_show_success(dt)
    if ShowSuccessTimer > 0 then
        ShowSuccessTimer = ShowSuccessTimer - dt
    elseif ShowSuccessTimer > -1 then
        game.load_random_puzzle()
        ShowSuccessTimer = -1
    end
end

function game.resize()
    settings.update_relative_vars()
    LabelFont = love.graphics.newFont("resources/labelFont.ttf", LabelFontSize)
    MenuFont = love.graphics.newFont("resources/labelFont.ttf", MenuFontSize)
    RatingFont = love.graphics.newFont("resources/labelFont.ttf", RatingFontSize)
    local _, _, flags = love.window.getMode()
    if flags.fullscreen then
        LevelDropdown.height = 27
    else
        LevelDropdown.height = 22
    end
    game.debug("RatingFontSize: " .. RatingFontSize)
end

function game.quit()
    game.write_user_ratings()
    game.write_resolved_puzzles()
end

return game
