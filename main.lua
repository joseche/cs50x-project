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
			love.window.setMode(800, 600, {
				fullscreen = not flags.fullscreen,
				resizable = true,
				minwidth = 800,
				minheight = 600
			})
			love.resize(800, 600)
		else
			love.event.quit()
		end
	end
end

function love.resize(w, h)
	ScreenWidth = w
	ScreenHeight = h
	CalculateRelativeScreenVariables()
end
