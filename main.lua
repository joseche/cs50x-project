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
end

function love.quit()
	game.quit()
end
