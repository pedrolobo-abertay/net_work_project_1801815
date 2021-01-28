SCREEN_SIZE = {x = 1920, y = 1080}

local socket = require "socket"
local address = "localhost"
local port = 12345
local UDP
local my_id
local game_over = false
local font_game_over
local title_font
local instructions_font
local wait_font
local state = "main_menu"
local wait_timer = 0
local max_timeout = 5
local using_interpolation = true
local ui_font

local players = {}
local projectiles = {}

function love.load()
  font_game_over = love.graphics.newFont("Fonts/PottaOne-Regular.ttf", 100)
  title_font = love.graphics.newFont("Fonts/PottaOne-Regular.ttf", 80)
  instructions_font = love.graphics.newFont("Fonts/PottaOne-Regular.ttf", 80)
  wait_font = love.graphics.newFont("Fonts/PottaOne-Regular.ttf", 50)
  ui_font = love.graphics.newFont("Fonts/PottaOne-Regular.ttf", 30)

  love.window.setMode(SCREEN_SIZE.x, SCREEN_SIZE.y)

  math.randomseed(os.time())

  UDP = socket.udp()

  UDP:settimeout(0)
  UDP:setpeername(address, port)

end

function love.draw()
  if state == "main_menu" then
    main_menu_draw()
  elseif state == "game" then
    game_draw()
  elseif state == "wait" then
    wait_draw()
  end
end

function love.update(dt)
  if state == "wait" then
    wait_timer = wait_timer + dt
    if wait_timer > max_timeout then
      wait_timer = max_timeout
    end
  elseif state == "game" and using_interpolation then
    for _, player in pairs(players) do
      player:update(dt)
    end
    for _, projectile in pairs(projectiles) do
      projectile:update(dt)
    end
  end
  receive_server_data()
end

function love.mousepressed(x, y, button)
  if not my_id or game_over or state ~= "game" then
    return
  end
  if button == 1 then
    local message = string.format("%s %s %s %d %d", my_id, "input", "shoot", x, y)
    UDP:send(message)
  end
end

function love.keypressed(key, scancode, isrepeat)
  if state == "game" then
    if not my_id or game_over then
      return
    end
    local message
    if key == "i" then
      using_interpolation = not using_interpolation
    elseif key == "w" then
      message = string.format("%s %s %s %s %s", my_id, "input", "movement", "up", "true")
    elseif key == "s" then
      message = string.format("%s %s %s %s %s", my_id, "input", "movement", "down", "true")
    elseif key == "d" then
      message = string.format("%s %s %s %s %s", my_id, "input", "movement", "right", "true")
    elseif key == "a" then
      message = string.format("%s %s %s %s %s", my_id, "input", "movement", "left", "true")
    end
    if message then
      UDP:send(message)
    end
  elseif state == "main_menu" then
    if key == "e" then
      local message = string.format("%d %s %s", -1, "new_player", "0")
      UDP:send(message)
      state = "wait"
      wait_timer = 0
    end
  elseif state == "wait" and key == "e" and wait_timer >= max_timeout then
    state = "main_menu"
  end
end

function love.keyreleased(key)
  if state == "game" then
    if not my_id or game_over then
      return
    end
    local message
    if key == "w" then
      message = string.format("%s %s %s %s %s", my_id, "input", "movement", "up", "false")
    elseif key == "s" then
      message = string.format("%s %s %s %s %s", my_id, "input", "movement", "down", "false")
    elseif key == "d" then
      message = string.format("%s %s %s %s %s", my_id, "input", "movement", "right", "false")
    elseif key == "a" then
      message = string.format("%s %s %s %s %s", my_id, "input", "movement", "left", "false")
    end
    if message then
      UDP:send(message)
    end
  end
end

function create_player(id, x, y, color, dx, dy)
  players[id] = require "player"({x = x, y = y}, color, dx, dy)
end

function create_projectile(id, x, y, owner, dx, dy)
  local color = players[owner].color
  color = {r=color.r, g=color.g, b=color.b}
  projectiles[id] = require "projectile"({x=x, y=y}, color, dx, dy)
end


function receive_server_data()
  local data, message
  repeat
    data, message = UDP:receive()
    if data then
      local command, args = data:match("^(%S+) (.*)")
      if command == "id" then
        my_id = tonumber(args)
        state = "game"
      elseif command == "pos" then
        local type, args2 = args:match("^(%S+) (.*)")
        if type == "player" then
          local id, x, y, r, g, b, dx, dy = args2:match("^(%S+) (%S+) (%S+) (%S+) (%S+) (%S+) (%S+) (%S+)")
          id = tonumber(id)
          if players[id] then
            players[id].pos.x = tonumber(x)
            players[id].pos.y = tonumber(y)
            players[id].mov_vec.x = tonumber(dx)
            players[id].mov_vec.y = tonumber(dy)
          else
            create_player(id, tonumber(x), tonumber(y), {r=tonumber(r), g=tonumber(g), b=tonumber(b)},
                          tonumber(dx), tonumber(dy))
          end
        elseif type == "projectile" then
          local id, x, y, owner, dx, dy = args2:match("^(table: %S+) (%S+) (%S+) (%S+) (%S+) (%S+)")
          if projectiles[id] then
            projectiles[id].pos.x = tonumber(x)
            projectiles[id].pos.y = tonumber(y)
            projectiles[id].direction.x = tonumber(dx)
            projectiles[id].direction.y = tonumber(dy)
          else
            create_projectile(id, tonumber(x), tonumber(y), tonumber(owner), tonumber(dx), tonumber(dy))
          end
        end
      elseif command == "kill" then
        local type, id_received = args:match("^(%S+) (.+)")
        if type == "projectile" then
          projectiles[id_received] = nil
        elseif type == "player" then
          local id_received = tonumber(id_received)
          table.remove(players, id_received)
          if id_received < my_id then
            my_id = my_id - 1
          elseif id_received == my_id then
            game_over = true
          end
        end
      elseif command == "update_health" then
        local id, health = args:match("^(%S+) (%S+)")
        players[tonumber(id)].health = tonumber(health)
      end
    elseif message ~= "timeout" then
      error("network error:"..tostring(message))
    end
  until not data
end

function game_draw()
  if game_over then
    love.graphics.setColor(1, 0, 1)
    love.graphics.setFont(font_game_over)
    local text = "YOU DIED"
    love.graphics.print(text, SCREEN_SIZE.x/2 - font_game_over:getWidth(text)/2,
                        SCREEN_SIZE.y/2 - font_game_over:getHeight(text)/2)
  end

  for _, player in pairs(players) do
    player:draw()
  end
  for i, projectile in pairs(projectiles) do
    projectile:draw()
  end
  love.graphics.setColor(0, 1, 1)
  love.graphics.setFont(ui_font)
  love.graphics.print("Using interpolation is: ".. tostring(using_interpolation), 5, 5)
end

function main_menu_draw()
  love.graphics.setColor(1, 0, 1)
  love.graphics.setFont(title_font)
  local title = "Welcome to my project"
  love.graphics.print(title, SCREEN_SIZE.x/2 - title_font:getWidth(title)/2, 200)

  local instructions = "Press the key 'e' to enter the game"
  love.graphics.setFont(instructions_font)
  love.graphics.print(instructions, SCREEN_SIZE.x/2 - instructions_font:getWidth(instructions)/2,
                      SCREEN_SIZE.y/2 - instructions_font:getHeight(instructions)/2)

end

function wait_draw()
  love.graphics.setColor(1, 0, 1)
  love.graphics.setFont(wait_font)
  local wait = "Waiting server to respond..."
  if wait_timer >= max_timeout then
    wait = "Server is not responding, press 'e' to return to menu"
  end
  love.graphics.print(wait, SCREEN_SIZE.x/2 - wait_font:getWidth(wait)/2, 500)

end
