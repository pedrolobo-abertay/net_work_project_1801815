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
  --Player
  love.graphics.setColor(self.color.r, self.color.g, self.color.b)
  love.graphics.circle("fill", self.pos.x, self.pos.y, self.radius)
  --Health bar
  local health_bar_w = 50
  local health_bar_h = 10
  local health_bar_vmargin = 10
  local bar_x = self.pos.x - health_bar_w/2
  local bar_y = self.pos.y - self.radius - health_bar_h - health_bar_vmargin
  love.graphics.setLineWidth(2)
  love.graphics.setColor(1, 1, 1)
  love.graphics.rectangle("line", bar_x, bar_y, health_bar_w, health_bar_h)
  love.graphics.setColor(1, 0, 0)
  love.graphics.rectangle("fill", bar_x, bar_y,
                          (self.health/self.max_health)*health_bar_w, health_bar_h)

end

local function _update(self, dt)
  normalize(self.mov_vec)

  self.pos.x = self.pos.x + self.mov_vec.x * dt * self.speed
  self.pos.y = self.pos.y + self.mov_vec.y * dt * self.speed

  self.pos.x = math.min(self.pos.x, SCREEN_SIZE.x - self.radius)
  self.pos.x = math.max(self.pos.x, self.radius)

  self.pos.y = math.min(self.pos.y, SCREEN_SIZE.y - self.radius)
  self.pos.y = math.max(self.pos.y, self.radius)
end

local function _create_player(pos, color, dx, dy)
  local player = {
    mov_vec = {x = dx, y = dy},
    radius = 20,
    speed = 500,
    pos = {x = pos.x, y = pos.y},
    type = "player",
    color = color,
    health = 100,
    max_health = 100,

    --functions
    draw = _draw,
    update = _update,
  }
  return player
end

return _create_player
