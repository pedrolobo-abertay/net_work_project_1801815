SCREEN_SIZE = {x = 1920, y = 1080}

local socket = require "socket"
local port = 12345
local UDP

local players = {}
local projectiles = {}
local active_player
local player_number = 0
local PLAYER_MAX = 4
local players_info = {}
local AVAILABLE_COLORS = {
  {r = 1, g = 0, b = 0},
  {r = 0, g = 1, b = 0},
  {r = 0, g = 0, b = 1},
  {r = 1, g = 1, b = 1},
  {r = 0, g = 1, b = 1},
  {r = 1, g = 0, b = 1},
}

function love.load()
  love.math.setRandomSeed(love.timer.getTime())

  UDP = socket.udp()
  UDP:setsockname("*", port)
  UDP:settimeout(0)
end

function love.update(dt)

  receive_client_data()

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
      local message = string.format("%s %s %d", "kill", "player", i)
      for j, info in ipairs(players_info) do
        UDP:sendto(message, info.ip, info.port)
      end
      table.remove(players, i)
      table.remove(players_info, i)
      player_number = player_number - 1
    end
  end
  for i = 1, #players_info do
    players_info[i].id = i
    players[i].id = i
  end

  for i = #projectiles, 1, -1 do
    if projectiles[i].kill then
      local message = string.format("%s %s %s", "kill", "projectile", tostring(projectiles[i]))
      for i, info in ipairs(players_info) do
        UDP:sendto(message, info.ip, info.port)
      end
      table.remove(projectiles, i)
    end
  end

  send_world_state()

end

function love.keypressed(key, scancode, isrepeat)
end


function create_player(id)
  local pos = {}
  local color = {}
  local margin = 20
  player_number = player_number + 1
  if not active_player then
    active_player = 1
  end

  local chosen_color
  repeat
    local valid = true
    chosen_color = AVAILABLE_COLORS[math.random(1, #AVAILABLE_COLORS)]
    for _, player in pairs(players) do
      if player.color.r == chosen_color.r and
         player.color.g == chosen_color.g and
         player.color.b == chosen_color.b then
        valid = false
        break
      end
    end
  until valid

  color.r = chosen_color.r
  color.g = chosen_color.g
  color.b = chosen_color.b

  pos.x = love.math.random(margin, SCREEN_SIZE.x - margin)
  pos.y = love.math.random(margin, SCREEN_SIZE.y - margin)

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
           local message = string.format("%s %d %d", "update_health", player.id, player.health)
           for _, info in pairs(players_info) do
             UDP:sendto(message, info.ip, info.port)
           end
      end
    end
  end
end

function receive_client_data()
  local data, msg_or_ip, port_or_nil
  local id, command, args

  data, msg_or_ip, port_or_nil = UDP:receivefrom()

  if data then
    id, command, args = data:match("^(%S+) (%S*) (.*)")
    id = tonumber(id)
    if command == "new_player" then
      if player_number < PLAYER_MAX then
        create_player(player_number+1)
        table.insert(players_info, {id = player_number, ip = msg_or_ip, port = port_or_nil})
        local message = string.format("%s %s", "id", tostring(player_number))
        UDP:sendto(message, msg_or_ip, port_or_nil)
      end
    elseif command == "input" then
      local type, args2 = args:match("^(%S+) (.*)")
      if type == "movement" then
        local direction, state = args2:match("^(%S+) (%S+)")
        players[id]:handle_input("movement", {direction = direction, state = state == "true"})
      elseif type == "shoot" then
        local x, y = args2:match("^(%S+) (%S+)")
        players[id]:handle_input("shoot", {mouse = {x = x, y = y}})
      end
    end
  elseif msg_or_ip ~= "timeout" then
    error("unknown network error:"..tostring(msg_or_ip))
  end
end

function send_world_state()
  for _, info in ipairs(players_info) do
    for i, player in ipairs(players) do
      local message = string.format("%s %s %d %d %d %d %d %d %d %d", "pos", "player",
                                    i, player.pos.x, player.pos.y, player.color.r, player.color.g, player.color.b,
                                    player.mov_vec.x, player.mov_vec.y)
      UDP:sendto(message, info.ip, info.port)
    end
    for i, projectile in ipairs(projectiles) do
      local message = string.format("%s %s %s %d %d %d %d %d", "pos", "projectile",
                                    tostring(projectile), projectile.pos.x, projectile.pos.y, projectile.owner,
                                    projectile.direction.x, projectile.direction.y)
      UDP:sendto(message, info.ip, info.port)
    end
  end
end
