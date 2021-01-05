
local function normalize(mov_vec)

  local l=(mov_vec.x * mov_vec.x + mov_vec.y * mov_vec.y)^.5

  if l == 0 then
    return
  end

  mov_vec.x = mov_vec.x/l
  mov_vec.y = mov_vec.y/l
end

function _draw(self)
  love.graphics.setColor(1.0, 0.5, 0.5)

  love.graphics.circle("fill", self.pos.x, self.pos.y, self.radius)
end

local function _update(self, dt)
  self.mov_vec = {x = 0, y = 0};
  if self.movement_input.up then
    self.mov_vec.y = self.mov_vec.y - 1
  end
  if self.movement_input.down then
    self.mov_vec.y = self.mov_vec.y + 1
  end
  if self.movement_input.right then
    self.mov_vec.x = self.mov_vec.x + 1
  end
  if self.movement_input.left then
    self.mov_vec.x = self.mov_vec.x - 1
  end

  normalize(self.mov_vec)

  self.pos.x = self.pos.x + self.mov_vec.x * dt * self.speed
  self.pos.y = self.pos.y + self.mov_vec.y * dt * self.speed

  --[[
  if timer_on then
    time = time + dt
  	if time >= timeLimit then
  		time = 0
      timer_on = false
  	end
  end]]

end

local function _handle_input(self, input, args)

  if input == "shoot" and not timer_on then
    local startX = player1.x + player1.width / 2
    local startY = player1.y + player1.height / 2
    local mouseX = x
    local mouseY = y

    local angle = math.atan2((mouseY - startY), (mouseX - startX))

    local bulletDx = bullet_speed * math.cos(angle)
    local bulletDy = bullet_speed * math.sin(angle)

    table.insert(bullets, {x = startX, y = startY, dx = bulletDx, dy = bulletDy})

    timer_on = true
  elseif input == "movement" then
    self.movement_input[args.direction] = args.state
  end
end

local function _create_player(pos)
  local player = {

    mov_vec = {x = 0, y = 0},
    radius = 10,
    shoot_cooldown = 1,
  	shoot_timer = 0,
    speed = 500,
    pos = {x = pos[1], y = pos[2]},
    type = "player",

    movement_input = {up = false, down = false, left = false, right = false},

    --functions
    draw = _draw,
    update = _update,
    handle_input = _handle_input,
  }
  return player
end

return _create_player
