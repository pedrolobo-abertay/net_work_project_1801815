SCREEN_SIZE = {x = 1920, y = 1080}

local socket = require "socket"
local address = "localhost"
local port = 12345
local UDP
local id


local players = {}
local projectiles = {}

function love.load()

  love.window.setMode(SCREEN_SIZE.x, SCREEN_SIZE.y)

  math.randomseed(os.time())

  UDP = socket.udp()

  UDP:settimeout(0)
  UDP:setpeername(address, port)

  local message = string.format("%d %s %s", -1, "new_player", "0")

  UDP:send(message)
end

function love.draw()
  for _, player in pairs(players) do
    player:draw()
  end
  for i, projectile in pairs(projectiles) do
    projectile:draw()
  end
end

function love.update(dt)
  receive_server_data()
end

function love.mousepressed(x, y, button)
  if not id then
    return
  end
  if button == 1 then
    local message = string.format("%s %s %s %d %d", id, "input", "shoot", x, y)
    UDP:send(message)
  end
end

function love.keypressed(key, scancode, isrepeat)
  if not id then
    return
  end
  local message
  if key == "w" then
    message = string.format("%s %s %s %s %s", id, "input", "movement", "up", "true")
  elseif key == "s" then
    message = string.format("%s %s %s %s %s", id, "input", "movement", "down", "true")
  elseif key == "d" then
    message = string.format("%s %s %s %s %s", id, "input", "movement", "right", "true")
  elseif key == "a" then
    message = string.format("%s %s %s %s %s", id, "input", "movement", "left", "true")
  end
  if message then
    UDP:send(message)
  end
end

function love.keyreleased(key)
  if not id then
    return
  end
  local message
  if key == "w" then
    message = string.format("%s %s %s %s %s", id, "input", "movement", "up", "false")
  elseif key == "s" then
    message = string.format("%s %s %s %s %s", id, "input", "movement", "down", "false")
  elseif key == "d" then
    message = string.format("%s %s %s %s %s", id, "input", "movement", "right", "false")
  elseif key == "a" then
    message = string.format("%s %s %s %s %s", id, "input", "movement", "left", "false")
  end
  if message then
    UDP:send(message)
  end
end

function create_player(id, x, y)
  players[id] = require "player"({x = x, y = y})
end

function create_projectile(id, x, y)
  projectiles[id] = require "projectile"({x=x, y=y})
end


function receive_server_data()
  local data, message
  repeat
    data, message = UDP:receive()
    if data then
      local command, args = data:match("^(%S+) (.*)")
      if command == "id" then
        id = args
      elseif command == "pos" then
        local type, id, args2 = args:match("^(%S+) (table: %S+) (.*)")
        if type == "player" then
          local x, y = args2:match("^(%S+) (%S+)")
          if players[id] then
            players[id].pos.x = tonumber(x)
            players[id].pos.y = tonumber(y)
          else
            create_player(id, tonumber(x), tonumber(y))
          end
        elseif type == "projectile" then
          local x, y = args2:match("^(%S+) (%S+)")
          if projectiles[id] then
            projectiles[id].pos.x = tonumber(x)
            projectiles[id].pos.y = tonumber(y)
          else
            create_projectile(id, tonumber(x), tonumber(y))
          end
        end
      elseif command == "kill" then
        local type, id = args:match("^(%S+) (table: %S+)")
        if type == "projectile" then
          projectiles[id] = nil
        elseif type == "player" then
          players[id] = nil
        end
      end
    elseif message ~= "timeout" then
      error("network error:"..tostring(message))
    end
  until not data
end
