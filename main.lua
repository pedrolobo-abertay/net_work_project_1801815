local player

function love.load()
  player = require "player"(100, 100)
end

function love.draw()
  player.draw()
end

function love.update(dt)

end

function love.mousepressed(x, y, button)

end
