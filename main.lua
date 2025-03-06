local game = require("game")

function love.load()
	game.load()
end

function love.draw()
	game.draw()
end

function love.keypressed(key)
	print("Key pressed: " .. key)
	if key == "escape" or key == "q" then
		love.event.quit()
	end
end
