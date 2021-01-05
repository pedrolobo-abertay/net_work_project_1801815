local player
local projectile

function love.load()
  love.window.setMode(1920, 1080)
  player = require "player"({100, 100})
  projectile = require "projectile"({300, 300}, {1, 1}, 1)
end

function love.draw()
  player:draw()
  projectile:draw()
end

function love.update(dt)
  player:update(dt)
  projectile:update(dt)
end

function love.mousepressed(x, y, button)

end

function love.keypressed(key, scancode, isrepeat)
  if key == "w" then
    player:handle_input("movement", {direction = "up", state = true})
  elseif key == "s" then
    player:handle_input("movement", {direction = "down", state = true})
  elseif key == "d" then
    player:handle_input("movement", {direction = "right", state = true})
  elseif key == "a" then
    player:handle_input("movement", {direction = "left", state = true})
  end
end

function love.keyreleased(key)
  if key == "w" then
    player:handle_input("movement", {direction = "up", state = false})
  elseif key == "s" then
    player:handle_input("movement", {direction = "down", state = false})
  elseif key == "d" then
    player:handle_input("movement", {direction = "right", state = false})
  elseif key == "a" then
    player:handle_input("movement", {direction = "left", state = false})
  end
end
