local game = require("game")

function love.load()
	game.load()
end

function love.draw()
	game.draw()
end

function love.keypressed(key)
	print("Key pressed: " .. key)
	if key == "q" then
		love.event.quit()
	end

	if key == "escape" then
		local _, _, flags = love.window.getMode()
		if flags.fullscreen then
			love.window.setMode(MinScreenWidth, MinScreenHeight, {
				fullscreen = not flags.fullscreen,
				resizable = false,
				minwidth = MinScreenWidth,
				minheight = MinScreenHeight
			})
			love.resize(MinScreenWidth, MinScreenHeight)
			-- else
			-- 	love.event.quit()
		end
	end
end

function love.resize(w, h)
	ScreenWidth = w
	ScreenHeight = h
	CalculateRelativeScreenVariables()
	LabelFont = love.graphics.newFont("resources/labelFont.ttf", LabelFontSize)
	MenuFont = love.graphics.newFont("resources/labelFont.ttf", MenuFontSize)
	RatingFont = love.graphics.newFont("resources/labelFont.ttf", RatingFontSize)
end

function love.mousepressed(x, y, button)
	if button == 1 then -- Left mouse button
		-- Calculate which square was clicked
		local clickedX = math.floor(x / SquareSize)
		local clickedY = math.floor(y / SquareSize)

		-- Check if the click is within the chessboard bounds
		if clickedX >= 0 and clickedX < 8 and clickedY >= 0 and clickedY < 8 then
			local file = clickedX + 1
			local rank = 8 - clickedY

			if SelectedSquare == nil then
				local cur_board_square = CurrentBoard[file][rank]
				print("current board position: " .. cur_board_square .. ", file:" .. file .. ",rank:" .. rank)
				-- No square is currently selected, so select the clicked square if there is a piece there
				if cur_board_square and cur_board_square ~= "" then
					SelectedSquare = { file = file, rank = rank }
					PieceMoving.quad = PieceQuads[cur_board_square]
					PieceMoving.piece = cur_board_square
					game.debug("Selected Square:")
					Pretty_print(SelectedSquare)
				end
			elseif file == SelectedSquare.file and rank == SelectedSquare.rank then
				game.debug("same square selected")
			else
				-- A square is already selected, so start blinking
				-- it doesn't matter if there is no piece in the newsquare
				NewSquare = { file = file, rank = rank }
				IsBlinking = true
				BlinkTimer = 0
				BlinkCount = 0

				-- this part is the piece animation
				PieceMoving.isMoving = true
				PieceMoving.origin_file = SelectedSquare.file
				PieceMoving.origin_rank = SelectedSquare.rank
				PieceMoving.target_file = NewSquare.file
				PieceMoving.target_rank = NewSquare.rank

				CurrentBoard[NewSquare.file][NewSquare.rank] = PieceMoving.piece
				CurrentBoard[SelectedSquare.file][SelectedSquare.rank] = ""

				PieceMoving.x = (PieceMoving.origin_file - 1) * SquareSize
				PieceMoving.y = (8 - PieceMoving.origin_rank) * SquareSize

				PieceMoving.targetX = (PieceMoving.target_file - 1) * SquareSize
				PieceMoving.targetY = (8 - PieceMoving.target_rank) * SquareSize

				PieceMoving.duration = 2
				PieceMoving.elapsed = 0
				Pretty_print(PieceMoving)
			end
		end

		-- check if a menu was clicked
		if LevelDropdown.isOpen == false then -- if the dropdown is open, button should not work
			for i, btn in ipairs(Main_menu.buttons) do
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
						game.load_puzzles_by_rating(UserRating())
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
end

function love.update(dt)
	-- Handle blinking logic
	if IsBlinking then
		BlinkTimer = BlinkTimer + dt
		if BlinkTimer >= 0.25 then -- Blink every 0.25 seconds
			BlinkTimer = 0
			BlinkCount = BlinkCount + 1
			if BlinkCount >= 4 then -- Blink twice (2 full cycles)
				SelectedSquare = nil -- Deselect both squares
				NewSquare = nil
				IsBlinking = false
				BlinkCount = 0
			end
		end
	end

	-- animate piece moving
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
		end
	end
end

function love.quit()
	game.quit()
end
