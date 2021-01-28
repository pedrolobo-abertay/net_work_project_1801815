local Projectile = require("projectile")

local function normalize(mov_vec)

  local l=(mov_vec.x * mov_vec.x + mov_vec.y * mov_vec.y)^.5

  if l == 0 then
    return
  end

  mov_vec.x = mov_vec.x/l
  mov_vec.y = mov_vec.y/l
end

local function _draw(self)
  love.graphics.setColor(self.color.r, self.color.g, self.color.b)

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

  self.pos.x = math.min(self.pos.x, SCREEN_SIZE.x - self.radius)
  self.pos.x = math.max(self.pos.x, self.radius)

  self.pos.y = math.min(self.pos.y, SCREEN_SIZE.y - self.radius)
  self.pos.y = math.max(self.pos.y, self.radius)

  self.shoot_timer = math.max(self.shoot_timer - dt, 0)

end

local function _handle_input(self, input, args)

  if input == "shoot" and self.shoot_timer <= 0 then
    self.shoot_timer = self.shoot_timer + self.shoot_cooldown

    local direction = {x = args.mouse.x - self.pos.x, y = args.mouse.y - self.pos.y}
    normalize(direction)
    local shade = .5
    local color = {r = self.color.r*shade, g = self.color.g*shade, b = self.color.b*shade}
    local projectile = Projectile(self.pos, direction, self.id, color)

    table.insert(self.bullets, projectile)

  elseif input == "movement" then
    self.movement_input[args.direction] = args.state
  end
end

local function _take_damage(self)
  self.health = self.health - self.damage
  if self.health <= 0 then
    self.dead = true
  end
end

local function _create_player(pos, id, color)
  local player = {

    health = 100,
    id = id,
    damage = 10,
    mov_vec = {x = 0, y = 0},
    radius = 10,
    shoot_cooldown = 0.3,
  	shoot_timer = 0,
    speed = 500,
    pos = {x = pos.x, y = pos.y},
    type = "player",
    bullets = {},
    color = {r = color.r, g = color.g, b = color.b},
    dead = false,
    movement_input = {up = false, down = false, left = false, right = false},

    --functions
    draw = _draw,
    update = _update,
    handle_input = _handle_input,
    take_damage = _take_damage,
  }
  return player
end

return _create_player
