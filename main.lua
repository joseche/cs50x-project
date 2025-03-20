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

	if key == "f" then
		local desktopWidth, desktopHeight = love.window.getDesktopDimensions()
		love.window.setMode(desktopWidth, desktopHeight, { fullscreen = true, fullscreentype = "exclusive" })
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
	if button == 1 and not PieceMoving.isMoving then -- Left mouse button
		-- Calculate which square was clicked
		local clickedX = math.floor(x / SquareSize)
		local clickedY = math.floor(y / SquareSize)

		-- Check if the click is within the chessboard bounds
		if clickedX >= 0 and clickedX < 8 and clickedY >= 0 and clickedY < 8 then
			-- inside here is the board logic, probably its better to take code out to functions
			local file = clickedX + 1
			local rank = 8 - clickedY

			if SelectedSquare == nil then
				local selected_piece = CurrentBoard[file][rank]
				if not game.valid_piece_turn(selected_piece) then
					ErrorSound:play()
					return -- dont select pieces that are not playing / corresponding turn
				end

				print("current board position: " .. selected_piece .. ", file:" .. file .. ",rank:" .. rank)
				-- No square is currently selected, so select the clicked square if there is a piece there
				if selected_piece and selected_piece ~= "" then
					SelectedSquare = { file = file, rank = rank }
					PieceMoving.quad = PieceQuads[selected_piece]
					PieceMoving.piece = selected_piece
					game.debug("Selected Square:")
					Pretty_print(SelectedSquare)
				end
			elseif file == SelectedSquare.file and rank == SelectedSquare.rank then
				game.debug("same square selected, deselecting it")
				SelectedSquare = nil
			else
				-- A square is already selected, so start blinking
				-- it doesn't matter if there is no piece in the newsquare
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
						game.update_rating()
					else
						OnSound:play()
						print("user clicked the correct move!")
						PieceMoving.next_func = function()
							game.start_move(CurrentPuzzle.moves[CurrentPuzzle.move_index], 2)
							CurrentPuzzle.move_index = CurrentPuzzle.move_index + 1
							PieceMoving.next_func = nil
							ComputerMove:play()
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
			CurrentBoard[PieceMoving.target_file][PieceMoving.target_rank] = PieceMoving.piece

			if type(PieceMoving.next_func) == "function" then
				PieceMoving.next_func()
			end
		end
	end

	if ShowSuccessTimer > 0 then
		ShowSuccessTimer = ShowSuccessTimer - dt
	elseif ShowSuccessTimer > -1 then
		game.load_random_puzzle()
		ShowSuccessTimer = -1
	end
end

function love.quit()
	game.quit()
end
