function love.load()

  bullet_speed = 800
  mov_vec = {x = 0, y = 0}
  new_pos =  {0, 0}
  time = 0
	timeLimit = 0
  timer_on = false

  love.window.setMode(1920, 1080)

  bullets = {}

end

local function _draw(self)

  love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

  love.graphics.setColor(1.0, 0.5, 0.5)
	for i,v in ipairs(bullets) do
		love.graphics.circle("fill", v.x, v.y, 10)
	end

end

local function _update(dt)
  if love.keyboard.isDown("w") then
    mov_vec.y = mov_vec.y - 1
  elseif love.keyboard.isDown("s") then
    mov_vec.y = mov_vec.y + 1
  elseif love.keyboard.isDown("d") then
    mov_vec.x = mov_vec.x + 1
  elseif love.keyboard.isDown("a") then
    mov_vec.x = mov_vec.x - 1
  end

  new_pos[1] = player1.x + mov_vec.x * dt * player1.speed
  new_pos[2] = player1.y + mov_vec.y * dt * player1.speed

  if new_pos[1] > 10 and new_pos[1] < 1920 - 50 and new_pos[2] > 10 and new_pos[2] < 1080 - 50 then
    player1.x = new_pos[1]
    player1.y = new_pos[2]
  else
    new_pos[1] = player1.x
    new_pos[2] = player1.y
  end

  mov_vec.x = 0
  mov_vec.y = 0

  for i, v in ipairs(bullets) do
  		v.x = v.x + (v.dx * dt)
  		v.y = v.y + (v.dy * dt)
        if v.x < 10 or v.x > 1920 - 50 or v.y < 10 or v.y > 1080 - 500 then
          table.remove(bullets)
        end
  	end

  if timer_on then
    time = time + dt
  	if time >= timeLimit then
  		time = 0
      timer_on = false
  	end
  end

end

local function  _handle_input(up, down, left, right, shoot)

  if button == 1 and not timer_on then
    local startX = player1.x + player1.width / 2
    local startY = player1.y + player1.height / 2
    local mouseX = x
    local mouseY = y

    local angle = math.atan2((mouseY - startY), (mouseX - startX))

    local bulletDx = bullet_speed * math.cos(angle)
    local bulletDy = bullet_speed * math.sin(angle)

    table.insert(bullets, {x = startX, y = startY, dx = bulletDx, dy = bulletDy})

    timer_on = true
  end
end

local function _create_player(pos)
  local player = {

    pos = {pos[1], pos[2]},
    new_pos =  {pos[1], pos[2]},

    type = "player",

    level = level,

    --functions
    draw = _draw,
    update_pos = _update_pos,
    update_new_pos = _update_new_pos,
    handle_input = _handle_input
  }
  return player
end

return _create_player
