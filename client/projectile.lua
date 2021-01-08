function _draw(self)

  love.graphics.setColor(self.color.r, self.color.g, self.color.b)

  love.graphics.circle("fill", self.pos.x, self.pos.y, self.radius)

end

function _update(self, dt)

  self.pos.x = self.pos.x + self.direction.x * dt * self.speed
  self.pos.y = self.pos.y + self.direction.y * dt * self.speed

  if self.pos.x + self.radius < 0 or self.pos.x - self.radius  > SCREEN_SIZE.x or
     self.pos.y + self.radius < 0 or self.pos.y - self.radius > SCREEN_SIZE.y then
    self.kill = true
  end
end

function _create_projectile(pos)

  local projectile = {
    radius = 10,
    speed = 500,
    pos = {x = pos.x, y = pos.y},
    type = "projectile",
    color = {r = 1, g = 1, b = 1},
    draw = _draw,
  }
  return projectile

end

return _create_projectile
