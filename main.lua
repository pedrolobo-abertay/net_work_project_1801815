SCREEN_SIZE = {x = 1920, y = 1080}
local player
local projectiles = {}

function love.load()
  love.window.setMode(SCREEN_SIZE.x, SCREEN_SIZE.y)
  player = require "player"({x = 100, y = 100})
end

function love.draw()
  player:draw()
  for i, projectile in ipairs(projectiles) do
    projectile:draw()
  end
end

function love.update(dt)
  player:update(dt)
  for i, bullet in ipairs(player.bullets) do
    table.insert(projectiles, bullet)
    table.remove(player.bullets)
  end
  for i, projectile in ipairs(projectiles) do
    projectile:update(dt)
  end
  for i = #projectiles, 1, -1 do
    if projectiles[i].kill then
      table.remove(projectiles, i)
    end
  end
end

function love.mousepressed(x, y, button)
  if button == 1 then
    player:handle_input("shoot", {mouse = {x = x, y = y}})
  end
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

function create_projectile(pos, direction, onwer)
  table.insert(projectiles, require "projectile" (pos, direction, onwer))
end
