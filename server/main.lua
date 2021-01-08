SCREEN_SIZE = {x = 1920, y = 1080}

local socket = require "socket"
local port = 12345
local UDP

local players = {}
local projectiles = {}
local active_player
local player_number = 0
local PLAYER_MAX = 4

function love.load()
  UDP = socket.udp()
  UDP:setsockname("*", port)
  UDP:settimeout(0)
end

function love.draw()
  for _, player in ipairs(players) do
    player:draw()
  end
  for i, projectile in ipairs(projectiles) do
    projectile:draw()
  end
end

function love.update(dt)
  local data, msg_or_ip, port_or_nil
  local id, command, args

  data, msg_or_ip, port_or_nil = UDP:receivefrom()

  if data then
    print(data)
    id, command, args = data:match("^(%d+) (%S*) (.*)")
    print(id, command, args)
  elseif msg_or_ip ~= "timeout" then
    error("unknown network error:"..tostring(msg_or_ip))
  end

  for _, player in ipairs(players) do
    player:update(dt)

    for i, bullet in ipairs(player.bullets) do
      table.insert(projectiles, bullet)
      table.remove(player.bullets)
    end
  end

  for i, projectile in ipairs(projectiles) do
    projectile:update(dt)
  end

  check_collisions()

  for i = #players, 1, -1 do
    if players[i].dead then
      table.remove(players, i)
    end
  end

  for i = #projectiles, 1, -1 do
    if projectiles[i].kill then
      table.remove(projectiles, i)
    end
  end
end

function love.mousepressed(x, y, button)
  if active_player then
    if button == 1 then
      players[active_player]:handle_input("shoot", {mouse = {x = x, y = y}})
    end
  end
end

function love.keypressed(key, scancode, isrepeat)
  if key == "q" and player_number < PLAYER_MAX then
    create_player(player_number+1)
  end

  if active_player then
    if key == "w" then
      players[active_player]:handle_input("movement", {direction = "up", state = true})
    elseif key == "s" then
      players[active_player]:handle_input("movement", {direction = "down", state = true})
    elseif key == "d" then
      players[active_player]:handle_input("movement", {direction = "right", state = true})
    elseif key == "a" then
      players[active_player]:handle_input("movement", {direction = "left", state = true})
    end

    if key == "c" then
      active_player = active_player%player_number + 1
    end
  end
end

function love.keyreleased(key)
  if active_player then
    if key == "w" then
      players[active_player]:handle_input("movement", {direction = "up", state = false})
    elseif key == "s" then
      players[active_player]:handle_input("movement", {direction = "down", state = false})
    elseif key == "d" then
      players[active_player]:handle_input("movement", {direction = "right", state = false})
    elseif key == "a" then
      players[active_player]:handle_input("movement", {direction = "left", state = false})
    end
  end
end

function create_player(id)
  local pos, color
  player_number = player_number + 1
  if not active_player then
    active_player = 1
  end

  if id == 1 then
    pos = {x = 100, y = 100}
    color = {r = 1, g = 1, b = 1}
  elseif id == 2 then
    pos = {x = 100, y = 500}
    color = {r = 0, g = 1, b = 1}
  elseif id == 3 then
    pos = {x = 500, y = 100}
    color = {r = 1, g = 0, b = 1}
  elseif id == 4 then
    pos = {x = 500, y = 500}
    color = {r = 1, g = 1, b = 0}
  end

  table.insert(players, require "player"({x = pos.x, y = pos.y}, id, color))
end

function check_collisions()
  for _, player in ipairs(players) do
    for _, projectile in ipairs(projectiles) do
      local distance = math.sqrt(math.pow(player.pos.x - projectile.pos.x, 2) + math.pow(player.pos.y - projectile.pos.y, 2))
      if distance < player.radius + projectile.radius and
         player.id ~= projectile.owner then
           player:take_damage()
           projectile.kill = true
      end
    end
  end
end