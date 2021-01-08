SCREEN_SIZE = {x = 1920, y = 1080}

local socket = require "socket"
local address = "localhost"
local port = 12345
local UDP
local id

function love.load()

  love.window.setMode(SCREEN_SIZE.x, SCREEN_SIZE.y)

  math.randomseed(os.time())
  id = math.random(10000)

  UDP = socket.udp()

  UDP:settimeout(0)
  UDP:setpeername(address, port)

  local message = string.format("%d %s %s", id, "new_player", "test")

  UDP:send(message)
end
