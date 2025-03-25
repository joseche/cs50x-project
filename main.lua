dofile("globals.lua")

local settings = require("settings")
local game = require("game")
-- local utils = require("utils")


function love.load()
	math.randomseed(os.time())
	game.debug("love load")
	settings.update_relative_vars()
	game.load()
end

function love.draw()
	game.draw()
end

function love.keypressed(key)
	print("Key pressed: " .. key)
	if key == "q" then
		love.event.quit()
	elseif key == "escape" then
		local _, _, flags = love.window.getMode()
		if flags.fullscreen then
			love.window.setMode(MinScreenWidth, MinScreenHeight, {
				fullscreen = false,
				resizable = false,
				minwidth = settings.MinScreenWidth,
				minheight = settings.MinScreenHeight
			})
			love.resize(MinScreenWidth, MinScreenHeight)
		end
	elseif key == "f" then
		local desktopWidth, desktopHeight = love.window.getDesktopDimensions()
		love.window.setMode(desktopWidth, desktopHeight, { fullscreen = true, fullscreentype = "exclusive" })
		love.resize(desktopWidth, desktopHeight)
	end
end

function love.resize(w, h)
	game.debug("love resize")
	ScreenWidth = w
	ScreenHeight = h
	settings.update_relative_vars()
	game.resize()

	if love.window then
		local _, _, flags = love.window.getMode()
		if flags.fullscreen then
			MainMenu_X = math.floor((SquareSize * 8) + 20)
			MainMenu_Y = math.floor(SquareSize * 6) + 60
			MainMenu_Width = ScreenWidth - MainMenu_X - 10
		end
	end
end

function love.mousepressed(x, y, button)
	if button == 1 and not PieceMoving.isMoving then -- Left mouse button
		--if button == 1 then -- Left mouse button
		-- Calculate which square was clicked
		local clickedX = math.floor(x / SquareSize)
		local clickedY = math.floor(y / SquareSize)

		-- Check if the click is within the chessboard bounds
		if clickedX >= 0 and clickedX < 8 and clickedY >= 0 and clickedY < 8 then
			-- inside here is the board logic, probably its better to take code out to functions
			local file = clickedX + 1
			local rank = 8 - clickedY
			game.board_clicked(file, rank)
		end

		game.check_buttons_clicked(x, y)
	end
end

function love.update(dt)
	game.update_blinking(dt)
	game.update_piece_moving(dt)
	game.update_show_success(dt)
end

function love.quit()
	game.quit()
end
