local Projectile = require("projectile")

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

  if input == "shoot" and self.shoot_timer <= 0 then
    self.shoot_timer = self.shoot_timer + self.shoot_cooldown

    local direction = {x = args.mouse.x, y = args.mouse.y}

    local projectile = Projectile(self.pos, direction, self.onwer)

    table.insert(self.bullets, projectile)

  elseif input == "movement" then
    self.movement_input[args.direction] = args.state
  end
end

local function _create_player(pos)
  local player = {

    owner = 1,
    mov_vec = {x = 0, y = 0},
    radius = 10,
    shoot_cooldown = 1,
  	shoot_timer = 0,
    speed = 500,
    pos = {x = pos.x, y = pos.y},
    type = "player",
    bullets = {},

    movement_input = {up = false, down = false, left = false, right = false},

    --functions
    draw = _draw,
    update = _update,
    handle_input = _handle_input,
  }
  return player
end

return _create_player
