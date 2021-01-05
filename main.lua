local player
local projectiles = {}

function love.load()
  love.window.setMode(1920, 1080)
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
  --itera por projeteis do jogador
  for i, projectile in ipairs(projectiles) do
    projectile:update(dt)
  end
end

function love.mousepressed(x, y, button)
  if button == 1 then
    player:handle_input("shoot", {mouse = {x, y}})
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
