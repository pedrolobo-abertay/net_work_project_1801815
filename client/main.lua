local socket = require "socket"
local address = "localhost"
local port = 12345
local UDP
local id

function function love.load()

  math.randomseed(os.time())
  id = math.random(10000)

  UDP = socket.udp()

  UDP:settimeout(0)
  UDP:setpeername(address, port)

  local message = string.format("%d %s", id, "new_player")

  UDP:send(message)
end
