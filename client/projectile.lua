local function _draw(self)

  love.graphics.setColor(self.color.r, self.color.g, self.color.b)

  love.graphics.circle("fill", self.pos.x, self.pos.y, self.radius)

end

local function _update(self, dt)
  self.pos.x = self.pos.x + self.direction.x * dt * self.speed
  self.pos.y = self.pos.y + self.direction.y * dt * self.speed
end

local function _create_projectile(pos, color, dx, dy)

  local projectile = {
    radius = 10,
    speed = 500,
    pos = {x = pos.x, y = pos.y},
    type = "projectile",
    color = {r = color.r, g = color.g, b = color.b},
    direction = {x = dx, y = dy},

    draw = _draw,
    update = _update,
  }
  return projectile
end

return _create_projectile
